require 'yaml'
require 'hashie'

module Twiddler
  class Configuration
    def self.load(yaml_path)
      @config_path = yaml_path
      @config = Hashie::Mash.load(yaml_path)
    end

    def self.config
      @config
    end

    def self.expand_path(path)
      File.expand_path(path, @config_path)
    end
  end
end
