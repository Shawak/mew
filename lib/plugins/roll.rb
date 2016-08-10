module Mew
  module Plugins
    # Rolls a dice
    module Roll
      extend Discordrb::Commands::CommandContainer
      command(:roll, description: 'Rolls a pokédice') do
        rand(1..6)
      end
    end
  end
end