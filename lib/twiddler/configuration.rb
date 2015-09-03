require 'yaml'
require 'hashie'
require 'slop'
require 'pathname'

module Twiddler
  class Configuration
    class << self
      attr_reader :config

      def load(opts)
        @config_path = File.expand_path(opts.delete(:config), Dir.pwd)
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
        end.to_hash.reject { |_, v| v.nil? }
      end

      def parse_and_load
        opts = parse_opts
        raise "must specify config file" unless opts[:config]
        load(opts)
      end

      def expand_path(path)
        File.expand_path(path, Pathname.new(@config_path).dirname)
      end

      def template_path
        expand_path(config.template)
      end

      def outfile_path
        expand_path(config.outfile)
      end
    end
  end
end
