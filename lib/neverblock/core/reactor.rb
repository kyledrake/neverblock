require 'eventmachine'
require 'thread'
require File.expand_path(File.dirname(__FILE__)+'/fiber')

module NeverBlock

  module EMHandler
    attr_accessor :read_fiber, :write_fiber

    def notify_readable
      @read_fiber.resume if @read_fiber
    end

    def notify_writable
      @write_fiber.resume if @write_fiber
    end
  end

  @@readers = {}
  @@writers = {}

  def self.reactor
    EM
  end

  def self.wait(mode, io)
    fiber = NB::Fiber.current

    meth, store = case mode
    when :read
      ["notify_readable", @@readers]
    when :write
      ["notify_writable", @@writers]
    else
      raise "Invalid mode #{mode.inspect}"
    end

    handler = @@readers[io.fileno] || @@writers[io.fileno] || EM.watch(io, EMHandler)
    handler.send("#{mode.to_s}_fiber=", fiber)
    handler.send("#{meth}=", true)
    store[io.fileno] = handler
    NB::Fiber.yield
    store.delete(io.fileno)
    # Is another fiber waiting for the same IO?
    if @@readers[io.fileno] || @@writers[io.fileno]
      handler.send("#{mode.to_s}_fiber=", nil)
      handler.send("#{meth}=", false)
    else
      handler.detach
    end
  end

  def self.sleep(time)
    NB::Fiber.yield if time.nil?
    return if time <= 0 
    fiber = NB::Fiber.current
    NB.reactor.add_timer(time){fiber.resume}
    NB::Fiber.yield
  end

end
