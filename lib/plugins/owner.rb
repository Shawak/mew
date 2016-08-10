module Mew
  module Plugins
    # Shows the owner
    module Owner
      extend Discordrb::Commands::CommandContainer
      command(:owner, description: 'show my owner!') do |event|
        'i\'m protecting <@166516277513420800> against evil demons!'
      end
    end
  end
end