module Mew
  module Plugins
    # Shows the ping to the server and back
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping, description: 'Piings') do |event|
        response = event.respond('Mew!')
        response.edit "Mew! (#{((response.timestamp - event.timestamp)*1000/2).round}ms)"
        nil
      end
    end
  end
end