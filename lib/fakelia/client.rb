module Fakelia
  # Client helper to ease metric generation
  module Client
    extend ActiveSupport::Concern
    
    # Instance methods for the default Fakelia::Client.
    module InstanceMethods
      # The units string on the graph.
      # 
      # @param [ String ] str The units displayed on the graph.
      # 
      # @note units for the value, e.g. 'kb/sec'
      # 
      # @return The units displayed on the graph.
      def units(str='req/min')
        @units ||= str
      end
      
      # The value type to use for the graph.
      # 
      # @param [ String ] str The ganglia unit type.
      # 
      # @note Possible values are:
      #   string, int8, uint8, int16, uint16, int32, uint32, float, double
      # 
      # @return The ganglia unit type.
      def type(str='unit8')
        @type ||= str
      end
      
      # The maximum time in seconds between gmetric calls.
      # 
      # @param [ Integer ] int The time in seconds.
      # 
      # @note Default value: 60
      # 
      # @return The time in seconds.
      def tmax(int=60)
        @tmax ||= int
      end
      
      # The lifetime in seconds of this metric.
      # 
      # @param [ Integer ] int The time in seconds.
      # 
      # @note Default value: 0, meaning unlimited.
      # 
      # @return The time in seconds.
      def dmax(int=0)
        @dmax ||= int
      end
      
      # Sets the sign of the derivative of the value over time.
      # 
      # @param [ String ] str The derivative of the value of the slope over time.
      # 
      # @note Possible values are:
      #   zero, positive, negative, both, default both.
      # 
      # @return The derivative of the value of the slope over time.
      def slope(str='both')
        @slope ||= str
      end
      
      # Helper to setup the graphing options for this client.
      # 
      # @param [ String ] name The name of the graph.
      # @param [ Proc ] &block The block to pass.
      # 
      # @return The graph options.
      def graph(name, &block)
        raise "Graph requires a name as the first parameter" if name.nil?
        instance_eval &block
        
        @graph_options = {}
        @graph_options.merge!({
          :hostname => '',
          :group => '',
          :spoof => false,
          :name => name,
          :units => units,
          :type => type,
          :tmax => tmax,
          :dmax => dmax,
          :slope => slope
        })
      end
      
      # Update the value of the ganglia graph with the block from the client.
      # 
      # @params [ Hash ] options The options passed from the Fakelia server.
      def update_ganglia(options = {})
        if methods.grep /update/
          send_to_ganglia(update, options)
        else
          raise Exception, "The update method for #{self} requires the :update method to be defined."
        end
      end
      
      def send_to_ganglia(value, options)
        host = options[:gmond_host]
        port = options[:gmond_port]
        options.delete(:gmond_host)
        options.delete(:gmond_port)
        
        data = @graph_options.merge({:value => value})
        data.merge!(options)
        Ganglia::GMetric.send(host, port, data)
      end
    end
  end
end
