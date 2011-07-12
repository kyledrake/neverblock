# Monkeypatch Net::BufferedIO#rbuf_fill
# use NeverBlock to wait on IO, not IO.select

module Net
  class BufferedIO

    def rbuf_fill
      timeout (@read_timeout) {
        begin
          @rbuf << @io.read_nonblock(BUFSIZE)
        rescue IO::WaitReadable, Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::EINTR => e
          NB.wait(:read, @io)
          retry
        rescue IO::WaitWritable => e
          NB.wait(:write, @io)
          retry
        end
      }
    end

  end
end
