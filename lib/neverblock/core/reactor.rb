require 'eventmachine'
require 'thread'
require File.expand_path(File.dirname(__FILE__)+'/fiber')

module NeverBlock

  module EMHandler
    def initialize(fiber)
      @fiber = fiber
    end

    def notify_readable
      @fiber.resume if @fiber
    end

    def notify_writable
      @fiber.resume if @fiber
    end
  end

  def self.reactor
    EM
  end

  def self.wait(mode, io)
    fiber = NB::Fiber.current

    meth = case mode
    when :read
      "notify_readable"
    when :write
      "notify_writable"
    else
      raise "Invalid mode #{mode.inspect}"
    end

    #puts "Waiting for #{mode.inspect}"

    fd = io.respond_to?(:to_io) ? io.to_io : io

    handler = EM.watch(fd, EMHandler, fiber)
    handler.send("#{meth}=", true)
    fiber[:io] = handler
    NB::Fiber.yield
    handler.detach
    fiber[:io] = nil
  end

  def self.sleep(time)
    NB::Fiber.yield if time.nil?
    return if time <= 0 
    fiber = NB::Fiber.current
    NB.reactor.add_timer(time){fiber.resume}
    NB::Fiber.yield
  end

end
