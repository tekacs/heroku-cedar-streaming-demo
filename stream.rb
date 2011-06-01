require 'rubygems'
require 'bundler'
Bundler.require

class Stream < Goliath::API
  def on_close(env)
    env.logger.info "Connection closed."
  end
  
  def response(env)
    
    # This timer keeps the connection alive later in the stream when
    # the number generation slows down sufficiently for > 30s response time.
    # Yes, the timer is something like 55s but I like 30s, okay? ;)
    keepalive = EM.add_periodic_timer(29) do
      env.stream_send("Heartbeat.\n")
    end
    
    EM.defer do
      i = 0
      n, m = 0, 1
      while true
        env.stream_send("#{i}: #{n}\n")
        n, m = m, n + m
        i += 1
      end
    end
    
    # The below cuts off the connection at some point if this is desired.
    # EM.add_timer(30) do
    #   keepalive.cancel
    #   
    #   env.stream_send("End of stream.")
    #   env.stream_close
    # end
    
    [200, {'Content-Type' => 'text/plain'}, Goliath::Response::STREAMING]
  end
end