require 'timeout'

module Timeout

  alias_method :rb_timeout, :timeout

  def timeout(time, klass=Timeout::Error, &block)
    return rb_timeout(time, klass,&block) unless NB.neverblocking?

    if time.nil? || time <= 0
      return block.call
    end

    fiber = NB::Fiber.current
    timeouts = (fiber[:timeouts] ||= [])

    timer = EM.add_timer(time) {
      idx = timeouts.index(timer)
      timers_to_cancel = timeouts.slice!(idx..timeouts.size-1)
      timers_to_cancel.each {|t| EM.cancel_timer(t) }
      # remove fiber[:io] - this indicates to the many_ticks block not to resume!
      handler = fiber[:io]
      fiber[:io] = nil
      handler.remove_waiter(fiber) if handler
      fiber.resume(Timeout::Error.new)
    }

    timeouts << timer

    ret = nil

    begin
      ret = block.call
    rescue Exception => e
      raise e
    ensure
      timeouts.delete(timer)
      EM.cancel_timer(timer)
    end

    ret
  end

  module_function :timeout
  module_function :rb_timeout

end
