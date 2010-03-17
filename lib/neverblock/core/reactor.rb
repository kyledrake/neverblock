require 'reactor'
require 'thread'
require File.expand_path(File.dirname(__FILE__)+'/fiber')

module NeverBlock

  @@reactors = {}

  def self.reactor
    @@reactors[Thread.current.object_id] ||= ::Reactor::Base.new
  end

  def self.wait(mode, io)
    fiber = NB::Fiber.current
    NB.reactor.attach(mode, io){fiber.resume}
    NB::Fiber.yield
    NB.reactor.detach(mode, io)
  end

  def self.sleep(time)
    NB::Fiber.yield if time.nil?
    return if time <= 0 
    fiber = NB::Fiber.current
    NB.reactor.add_timer(time){fiber.resume}
    NB::Fiber.yield
  end

end
