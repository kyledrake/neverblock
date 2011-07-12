require_relative "spec_helper"

describe TCPSocket, " without NeverBlock" do

  before(:all) do
    @server = TestServer.new :tcp_echo_server
    sleep 0.5
    @socket = TCPSocket.new "localhost", 8080
  end

  it "should connect, send, and receive data" do
    @socket.read(2).should == "hi"
    @socket.write "test"
    @socket.read(4).should == "test"
  end

  it "should not be mad concurrent" do
    start = Time.now
    20.times do
      socket = TCPSocket.new "localhost", 8080
      socket.read(2).should == "hi"
      socket.write "test"
      socket.read(4).should == "test"
    end
    (Time.now - start).should >=  1
  end

  after(:all) do
    @server.stop
  end

end

describe TCPSocket, " with NeverBlock" do

  before(:all) do
    @server = TestServer.new :tcp_echo_server
    sleep 0.5
  end

  it "should connect, send, and receive data" do
    EM.run {
      NB::Fiber.new do
        socket = TCPSocket.new "localhost", 8080
        socket.read(2).should == "hi"
        socket.write "test"
        socket.read(4).should == "test"
      end.resume
      EM.add_timer(0.1) { EM.stop }
    }
  end

  it "should be mad concurrent" do
    EM.run {
      start = Time.now
      10.times do
        NB::Fiber.new do
          socket = TCPSocket.new "localhost", 8080
          socket.read(2).should == "hi"
          socket.write "test"
          socket.read(4).should == "test"
          (Time.now - start).should <= 0.3
        end.resume
      end

      EM.add_timer(0.5) {
        EM.stop
      }
    }
  end


  after(:all) do
    @server.stop
  end

end
