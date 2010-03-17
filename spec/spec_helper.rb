require_relative "../lib/neverblock"

class TestServer
  attr_accessor :r, :w, :status
  
  def initialize server
    path = File.expand_path("../servers/#{server}.rb",__FILE__)
    puts path
    @r, @w = IO.popen "ruby #{path}"
    @status = $?
  end

  def stop
    Process.kill @status.pid
  end

end