module Fakelia
  # The generic fakelia app to run every module in your scripts folder.
  class Application
    # The default configuration parameters
    DEFAULT_CONFIGURATION = {
      :scripts_directory => 
        RUBY_PLATFORM =~ /mswin32/ ? 
          'c:\fakelia\scripts' : '/etc/fakelia/scripts',
      :gmond_host => '127.0.0.1',
      :gmond_port => 8649,
      :hostname => '',
      :group => '',
      :interval => 20
    }
    
    # Start the ganglia client/forwarder.
    # 
    # @param [ String ] config_file The location of the configuration file to use.
    def initialize(config_file=nil)
      get_configuration(config_file)
      setup_spoof
      start_event_loop
    end
    
    # Parse and merge the json configuration
    # 
    # @param [ String ] config_file The location of the configuration file to use.
    def get_configuration(config_file)
      @config = DEFAULT_CONFIGURATION
      if File.exists? config_file
        begin
          cfg = JSON.parse(open(config_file).read)
          @config.merge!(cfg.symbolize_keys!)
        rescue
        end
      end unless config_file.nil?
    end
    
    # Setup spoofing if a hostname is set in the configuration.
    def setup_spoof
      unless @config[:hostname].empty?
        @spoof = true
      end
    end
    
    # Start the main Fakelia event loop.
    def start_event_loop
      get_script_list
      setup_script_modules
      
      EM.run do
        @config.merge ({:spoof => @spoof})
        @class_objects ||= {}
        
        EM.add_periodic_timer(@config[:interval]) do
          @script_classes.each do |cls|
            unless @class_objects.has_key? cls.name
              @class_objects[cls] = cls.new(@config)
            end
            
            @class_objects[cls].update_ganglia(@config.select { |k, v|
              [:hostname, :group, :gmond_host, :gmond_port, :spoof].include? k
            })
          end
        end
      end
    end
    
    # Generates a list of files from the scripts directory.
    # 
    # @example
    #   module Fakelia::Scripts  
    #     class Example
    #       include Fakelia::Client
    #   
    #       graph "example graph" do
    #         units 'req/min'
    #         type 'uint8'
    #        end
    #  
    #       update do
    #         rand(100)
    #       end
    #     end
    #   end
    # 
    # @return The list of filenames excluding the .rb suffix.
    def get_script_list
      @scripts = Dir.glob("#{@config[:scripts_directory]}/*.rb")
      @scripts.map { |filename|
        filename[0...-3]
      }
    end
    
    # Sets up the list of script modules to use in the application
    # while also setting up the initial spoofing values.
    # 
    # @return The list of script modules
    def setup_script_modules
      @scripts.each do |scr|
        require scr
      end
      
      @script_classes = Fakelia::Scripts.constants.select { |c|
        Fakelia::Scripts.const_get(c).class == Class }
      @script_classes
    end
  end
end
