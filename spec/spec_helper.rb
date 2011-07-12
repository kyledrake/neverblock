require_relative "../lib/neverblock"

EM.error_handler {|e| $stderr.puts(e.message); $stderr.puts(e.backtrace.join("\n")) }

class TestServer

  def initialize server
    path = File.expand_path("../servers/#{server}.rb",__FILE__)
    @pid = spawn("ruby #{path}")
  end

  def stop
    Process.kill "INT", @pid
  end

end

class TestHTTPServer

  def initialize server
    path = File.expand_path("../servers/#{server}",__FILE__)
    @pid = spawn("thin -R #{path}.ru -p 8080 start")
  end

  def stop
    Process.kill "KILL", @pid
  end

end
