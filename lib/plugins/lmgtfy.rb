module Mew
  module Plugins
    # Generates a lmgtfy link
    module Lmgtfy
      extend Discordrb::Commands::CommandContainer
      command(:lmgtfy, min_args: 1,
              description: 'Generates Let Me Goole That For You link.',
              usage: 'lmgtfy <text>') do |event, *text|
        "http://lmgtfy.com/?q=#{text.join('+')}"
      end
    end
  end
end