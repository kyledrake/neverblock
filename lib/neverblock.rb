# Author::    Mohammad A. Ali  (mailto:oldmoe@gmail.com)
# Copyright:: Copyright (c) 2008 eSpace, Inc.
# License::   Distributes under the same terms as Ruby

module NeverBlock

  # Checks if we should be working in a non-blocking mode
  def self.neverblocking?
    NB::Fiber.respond_to?(:current) && NB::Fiber.current.respond_to?('[]') && NB::Fiber.current[:neverblock] && NB.reactor.reactor_running?
  end

  # The given block will run its queries either in blocking or non-blocking
  # mode based on the first parameter
  def self.neverblock(nb = true, &block)
    status = NB::Fiber.current[:neverblock]
    NB::Fiber.current[:neverblock] = nb
    block.call
    NB::Fiber.current[:neverblock] = status
  end

  # Exception to be thrown for all neverblock internal errors
  class NBError < StandardError
  end

end

NB = NeverBlock

require_relative 'neverblock/core/reactor'
require_relative 'neverblock/core/fiber'
require_relative 'neverblock/core/pool'

require_relative 'neverblock/core/system/system'
require_relative 'neverblock/core/system/timeout'

require_relative 'neverblock/io/socket'

require_relative 'neverblock/net/buffered_io'

require_relative 'neverblock/many_ticks'
require_relative 'neverblock/thin' if defined?(Thin)
