module Mew
  module Plugins
    # Flips a coin
    module Flip
      extend Discordrb::Commands::CommandContainer
      command(:flip, description: 'Flips a pokécoin') do
        %w(Heads Tails).sample
      end
    end
  end
end