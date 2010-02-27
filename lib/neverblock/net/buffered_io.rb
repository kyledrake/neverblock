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
        NB.wait(:read,self.io)
        retry
       rescue IO::WaitWritable => e
         NB.wait(:write,self.io)
         retry
      end
    end
    
  end 
end
