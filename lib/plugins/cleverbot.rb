module Mew
  module Plugins
    # Answers using cleverbot
    module CleverBot
      extend Discordrb::Commands::CommandContainer
      extend Discordrb::EventContainer

      Cleverbot = Cleverbot.new('phx4BbT1oEQjO5L0', '9o5RCOYI5rfW7fCDlZL4WvBWr4WjmLWd')
      command(:cb, description: 'Answers using cleverbot', min_args: 1, usage: 'cb <text>') do |event, *str|
        Thread.new do
          sleep 3
          event.respond('::cb ' + CGI.unescapeHTML(Cleverbot.say(str.join ' ')))
        end
        nil
      end

      pm do |event|
        event.respond(CGI.unescapeHTML(Cleverbot.say(event.content)).downcase)
      end
    end
  end
end