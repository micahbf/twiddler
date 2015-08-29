require 'unimidi'

class MIDIDevice
  attr_reader :midi_in, :midi_out

  def self.select_interactively
    midi_in = UniMIDI::Input.gets
    midi_out = UniMIDI::Output.find_by_name(midi_in.name)
    midi_out ||= UniMIDI::Output.gets
    new(in: midi_in, out: midi_out)
  end

  def initialize(midi_in:, midi_out:)
    @midi_in = midi_in
    @midi_out = midi_out
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
