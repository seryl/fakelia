module Fakelia::Scripts  
  module RandExample
    include Fakelia::Client
    
    graph "rand_graph" do
      units 'req/min'
      type 'uint8'
    end
    
    # Send random data.
    def self.update      
      rand(150)
    end
  end
end
