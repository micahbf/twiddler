require 'twiddler/configuration'
require 'twiddler/event_handler'
require 'twiddler/hud'
require 'twiddler/midi_device'
require 'twiddler/operator'
require 'twiddler/renderer'

module Twiddler
  def self.run
    config = Configuration.parse_and_load
    if config[:midi]
      midi_device = MIDIDevice.new_by_name(config[:midi])
    else
      midi_device = MIDIDevice.new_interactively
    end

    renderer = Renderer.new(config.template_path)

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
