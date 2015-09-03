require 'yaml'
require 'hashie'
require 'slop'

module Twiddler
  class Configuration
    class << self
      attr_reader :config

      def load(opts)
        @config_path = opts.delete(:config)
        yaml_opts = YAML.load_file(@config_path)
        @config = Hashie::Mash.new(yaml_opts.merge(opts))
      end

      def parse_opts
        Slop.parse do |o|
          o.string '-c', '--config', 'configuration file'
          o.string '-t', '--template', 'template file'
          o.string '-o', '--outfile', 'rendered output file'
          o.integer '-d', '--debounce', 'debounce time in msec'
          o.string '-m', '--midi', 'MIDI device name'
          o.on '-l', '--ls-midi', 'list available MIDI devices' do
            Twiddler::MIDIDevice.ls
            exit
          end
          o.on '-h', '--help', 'display this help' do
            puts o
            exit
          end
        end.to_hash
      end

      def parse_and_load
        opts = parse_opts
        raise "must specify config file" unless options[:config]
        load(opts)
      end

      def expand_path(path)
        File.expand_path(path, @config_path)
      end

      def template_path
        expand_path(config.template)
      end
    end
  end
end
