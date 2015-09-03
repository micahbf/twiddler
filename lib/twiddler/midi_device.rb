require 'unimidi'

module Twiddler
  class MIDIDevice
    class NoMIDIDeviceError < StandardError; end

    attr_reader :midi_in, :midi_out

    def self.new_interactively
      midi_in = UniMIDI::Input.gets
      midi_out = UniMIDI::Output.find_by_name(midi_in.name)
      midi_out ||= UniMIDI::Output.gets
      new(midi_in: midi_in, midi_out: midi_out)
    end

    def self.new_by_name(name)
      midi_in = UniMIDI::Input.find_by_name(name)
      midi_out = UniMIDI::Output.find_by_name(name)

      unless midi_in
        raise NoMIDIDeviceError, "no device found with name #{name}"
      end
      new(midi_in: midi_in, midi_out: midi_out)
    end

    def self.ls
      UniMIDI::Input.list
    end

    def initialize(midi_in:, midi_out:)
      @midi_in = midi_in
      @midi_out = midi_out
    end

    def listen
      raise ArgumentError, "block required" unless block_given?
      midi_in.open do |input|
        loop do
          event_data = input.gets[0][:data]
          yield process_event(event_data)
        end
      end
    end

    private

    EVENT_NIBBLES = {
      8  => :note_off,
      9  => :note_on,
      11 => :control_change
    }

    def process_event(event_bytes)
      status, data1, data2 = event_bytes
      event_nibble = status >> 4
      channel      = status % 16
      return unless event = EVENT_NIBBLES[event_nibble]
      {
        event: event,
        channel: channel,
        number: data1,
        value: data2
      }
    end
  end
end
