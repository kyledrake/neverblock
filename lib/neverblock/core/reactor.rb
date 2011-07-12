require 'eventmachine'
require 'thread'

module NeverBlock

  module EMHandler
    def initialize(fd)
      @fd = fd
      @readers = []
      @writers = []
    end

    def add_writer(fiber)
      fiber[:io] = self
      self.notify_writable = true
      @writers << fiber
    end

    def add_reader(fiber)
      fiber[:io] = self
      self.notify_readable = true
      @readers << fiber
    end

    def remove_waiter(fiber)
      @readers.delete(fiber)
      @writers.delete(fiber)
    end

    def notify_readable
      if f = @readers.shift
        # if f[:io] is nil, it means it was cleared by a timeout - dont resume!
        # make sure to set f[:io] to nil BEFORE resuming. if we set it after,
        # we'll clear any new value that was set during fiber.resume
        EM.many_ticks {
          if f[:io]
            f[:io] = nil
            f.resume
          end
        }
      else
        self.notify_readable = false
      end
      detach_if_done
    end

    def notify_writable
      if f = @writers.shift
        EM.many_ticks {
          if f[:io]
            f[:io] = nil
            f.resume
          end
        }
      else
        self.notify_writable = false
      end
      detach_if_done
    end

    def detach_if_done
      NB.remove_handler(@fd) if @readers.empty? && @writers.empty?
    end

  end

  def self.reactor
    EM
  end

  @@handlers = {}

  def self.wait(mode, io)
    fiber = NB::Fiber.current

    meth = case mode
    when :read
      :add_reader
    when :write
      :add_writer
    else
      raise "Invalid mode #{mode.inspect}"
    end

    fd = io.respond_to?(:to_io) ? io.to_io : io

    handler = (@@handlers[fd.fileno] ||= EM.watch(fd, EMHandler, fd.fileno))
    handler.send(meth, fiber)
    NB::Fiber.yield
  end

  def self.remove_handler(fd)
    if handler = @@handlers.delete(fd)
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
