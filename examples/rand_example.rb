module Fakelia::Scripts  
  class RandExample
    include Fakelia::Client
    
    def initialize
      graph "rand_graph" do
        units 'req/min'
        type 'uint8'
      end
    end
    
    # Send random data.
    def update      
      rand(150)
    end
  end
end
