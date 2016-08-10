module Mew
  module Plugins
    # Responds on mention
    module Mention
      extend Discordrb::EventContainer
      mention do |event|
        event.respond 'Mew!'
      end
    end
  end
end