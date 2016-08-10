# Gem
require 'discordrb'
require 'cleverbot'
require 'httparty'
require 'shorturl'

# Pre-Installed
require 'json'
require 'cgi' # (unescape html in cleverbot)
require 'net/http'

RAKE = false unless defined? RAKE

module Mew
  # Load own classes
  Dir["#{File.dirname(__FILE__)}/*.rb"].each { |file| require file }

  CONFIG = Config.new 'config.json', RAKE

  BOT = Discordrb::Commands::CommandBot.new(
      token: CONFIG.discord_token,
      application_id: CONFIG.owner_id,
      prefix: CONFIG.prefix)

  at_exit do
    puts 'Shutting down..'
  end

  def self.run
    puts "Ruby Version: #{RUBY_VERSION}"

    # Load plugins
    Dir["#{File.dirname(__FILE__)}/plugins/*.rb"].each { |file| require file }
    (Plugins.all_the_modules-[Plugins]).each do |plugin|
      BOT.include! plugin
    end

    # Start the bot
    BOT.run
  end

  run

end