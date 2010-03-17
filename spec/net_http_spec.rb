#require_relative "spec_helper"
#
#require 'net/http'
#
#describe Net::HTTP do
#  context " without NeverBlock" do
#
#    before(:all) do
#      #@server = TestHTTPServer.new :sleepy_http_server
#      #sleep 10
#    end
#
#    it "should still do a simple GET" do
#      http = Net::HTTP.start "127.0.0.1", 8080
#      get = Net::HTTP::Get.new "/hi"
#      resp = http.request(get)
#      resp.body.should == "hello"
#    end
#    
#  end
#
#  context " with NeverBlock" do
#
#    it "should still do a simple GET" do
#      EM.run {
#        NB::Fiber.new do
#          http = Net::HTTP.start "127.0.0.1", 8080
#          get = Net::HTTP::Get.new "/hi"
#          resp = http.request(get)
#          resp.body.should == "hello"
#        end.resume
#        EM.add_timer(0.1) { EM.stop }
#      }
#    end
#
#    it "should be mad concurrent" do
#      EM.run {
#        start = Time.now
#        10.times do
#          NB::Fiber.new do
#            http = Net::HTTP.start "127.0.0.1", 8080
#            get = Net::HTTP::Get.new "/1"
#            resp = http.request(get)
#            resp.body.should == "delayed for 1 seconds"
#          end
#        end
#        (Time.now - start).should <= 1.5
#        EM.add_timer(0.1) { EM.stop }
#      }
#      
#    end
#    
#    
#
#  end
#
#
#end
