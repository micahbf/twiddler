require_relative 'twiddler/configuration'
require_relative 'twiddler/event_handler'
require_relative 'twiddler/hud'
require_relative 'twiddler/midi_device'
require_relative 'twiddler/operator'
require_relative 'twiddler/renderer'

module Twiddler
  def self.run
    config = Configuration.parse_and_load

    if config[:midi]
      midi_device = MIDIDevice.new_by_name(config[:midi])
    else
      midi_device = MIDIDevice.new_interactively
    end

    renderer = Renderer.new(Configuration.template_path, Configuration.outfile_path)

    event_handler = EventHandler.new(
      config: config,
      midi_device: midi_device,
      renderer: renderer,
      operator: Operator.new,
      hud: HUD.new
    )

    event_handler.start
  end
end
