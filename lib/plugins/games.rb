module Mew
  module Plugins
    # Updates what the bot is playing
    module Games
      extend Discordrb::Commands::CommandContainer
      extend Discordrb::EventContainer

      @games = [
          'Pokémon',
          'with Mewtwo!',
          'with Fairy Tail'
      ]

      ready do
        Thread.new do
          while true do
            BOT.game = @games.sample
            sleep 60
          end
        end
      end
    end
  end
end