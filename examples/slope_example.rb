module Fakelia::Scripts  
  class SlopeExample
    include Fakelia::Client
    
    def initialize
      graph "slope_example" do
        units 'req/min'
        type 'uint8'
      end
    end
    
    # Generates a nicely sloped curve.
    def update
      if @growth.nil?
        @growth = true
      end
      @last_value ||= 5
      check_slope
      next_value
    end
  
    def check_slope      
      if @last_value < 4
        @growth = true
      elsif @last_value > 40
        @growth = false
      end
    end
  
    def next_value
      if @growth
        @last_value += 4
      else
        @last_value -= 4
      end
      @last_value
    end
  end
end
