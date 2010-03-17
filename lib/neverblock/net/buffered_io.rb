# Monkeypatch Net::BufferedIO#rbuf_fill
# use NeverBlock to wait on IO, not IO.select
#
# Doesn't do read timeouts yet, but... whatever. I don't care nearly as much
# if the timeout isn't blocking.

module Net
  class BufferedIO

    def rbuf_fill
      # todo: handle timeout
      begin
        @rbuf << @io.read_nonblock(BUFSIZE)
      rescue IO::WaitReadable => e
        if self.io.kind_of? OpenSSL::SSL::SSLSocket
          io = self.io.io
        else
          io = self.io
        end
        NB.wait(:read,io)
        retry
      rescue IO::WaitWritable => e
        if self.io.kind_of? OpenSSL::SSL::SSLSocket
          io = self.io.io
        else
          io = self.io
        end
        NB.wait(:write,io)
        retry
      end
    end
    
  end 
end
