require 'time'

module Twiddler
  class EventHandler
    attr_reader :midi_device, :config, :state, :operator, :renderer, :midi_events, :hud

    def initialize(midi_device:, config:, state: {}, operator:, renderer:, hud:)
      @midi_device = midi_device
      @config = config
      @state = state
      @operator = operator
      @renderer = renderer
      @hud = hud

      initialize_state if state.empty?
      initialize_midi_events
    end

    def initialize_state
      config.parameters.each do |param|
        # in lieu of pick-up, we initialize all the values to their median position
        update_state(param, 64)
      end
    end

    def start
      midi_device.listen do |midi_event|
        key = [midi_event[:event], midi_event[:channel], midi_event[:number]]
        param = midi_events[key]
        next unless param
        update_state(param, midi_event[:value])
      end
    end

    private

    def update_state(param, value)
      state[param[:name]] = {raw: value, value: operator.operate(param, value)}
      state_changed
    end

    def state_changed
      hud.update(state)
      debounce
    end

    def state_changed_debounced
      renderer.render_to_file(state)
      exec(config.callback) if config.callback
    end

    def initialize_midi_events
      @midi_events = {}
      config.parameters.each do |param|
        key = [param.midi_type, param.channel, param.number]
        midi_events[key] = param
      end
    end

    def debounce
      @debounce_mutex ||= Mutex.new
      @debounce_mutex.synchronize { @last_op = Time.now.to_f }

      Thread.new do
        time_sec = config.debounce / 1000.0
        sleep(time_sec)
        if Time.now.to_f - @debounce_mutex.synchronize { @last_op } >= time_sec
          state_changed_debounced
        end
        Thread.kill
      end
    end
  end
end
