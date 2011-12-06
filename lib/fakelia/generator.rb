$:.unshift File.join(File.dirname(__FILE__), '..')
require 'fakelia'

module Fakelia
  # 
  class Generator
    include Fakelia::Client
    
    # Creates a new Fakelia Generator
    # 
    # @example
    #   {
    #     :name => "rand_graph",
    #     :units => "req/min",
    #     :type => "uint8"
    #   }
    # 
    # @param [ Hash ] config The graph configuration
    def initialize(host, port, config)
      graph config[:name] do
        generate_graph_from config
        units 'req/min'
        type 'uint8'
      end
      
      require 'pp'
      pp @graph_options
    end
    
    def generate_graph_from(config)
      graph_opts = config.dup
      graph_opts.delete(:name)
      graph_opts.each_pair do |key, value|
        send(key, value)
      end
    end
  end
end

Fakelia::Generator.new({:name => "awesome", :units => "cool"})
