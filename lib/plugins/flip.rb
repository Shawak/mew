module Mew
  module Plugins
    # Flips a coin
    module Flip
      extend Discordrb::Commands::CommandContainer
      command(:flip, description: 'Fips a pokécoin') do
        %w(Heads Tails).sample
      end
    end
  end
end