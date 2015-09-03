require 'tty-table'

module Twiddler
  class HUD
    CLEAR = "\e[H\e[2J"

    def update(state)
      table = TTY::Table.new(header: %w(parameter MIDI value))
      state.each do |name, data|
        table << [name, data[:raw], data[:value]]
      end
      puts CLEAR
      puts table.render(:unicode)
    end
  end
end
