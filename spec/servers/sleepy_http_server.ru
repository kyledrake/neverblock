# See http://github.com/raggi/async_sinatra
# gem install async_sinatra -v0.1.5
require 'rubygems'
require 'sinatra/async'

class AsyncTest < Sinatra::Base
  register Sinatra::Async

  aget "/hi" do
    body { "hello" }
  end

  aget '/:n' do |n|
    EM.add_timer(n.to_i) { body { "delayed for #{n} seconds\n" } }
  end

end

run AsyncTest.new
