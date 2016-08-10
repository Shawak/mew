module Mew
  module Plugins
    # Answers using cleverbot

    # from https://github.com/radthebrown/ruby_cleverbot/blob/master/lib/ruby_cleverbot.rb
    class RubyCleverbot

      HOST = 'http://www.cleverbot.com'.freeze
      RESOURCE = '/webservicemin?uc=165&'.freeze
      API_URL = HOST + RESOURCE

      HEADERS = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cache-Control': 'no-cache'
      }

      attr_reader :cookies
      attr_reader :data
      attr_reader :conversation

      def initialize
        @data = {
            'stimulus': '',
            'start': 'y',
            'sessionid': '',
            'vText8': '',
            'vText7': '',
            'vText6': '',
            'vText5': '',
            'vText4': '',
            'vText3': '',
            'vText2': '',
            'icognoid': 'wsf',
            'icognocheck': '',
            'fno': 0,
            'prevref': '',
            'emotionaloutput': '',
            'emotionalhistory': '',
            'asbotname': '',
            'ttsvoice': '',
            'typing': '',
            'lineref': '',
            'sub': 'Say',
            'islearning': 1,
            'cleanslate': 'False',
        }
        #get the cookies
        response = make_get(HOST)
        @cookies = response.cookies
        @conversation = []
      end

      # call a get method
      def make_get(url)
        RestClient::Request.execute method: :get, url: url, headers: HEADERS, cookies: cookies
      end

      # call a post method
      def make_post(url, json)
        # RestClient.post url, json, headers
        RestClient::Request.execute method: :post, url: url, payload: URI.encode_www_form(json), headers: HEADERS, cookies: cookies
      end

      def send_message(question)
        # the current question
        data[:stimulus] = question

        # set data, for the conversation
        set_conversation

        # we need the token
        enc_data = URI.encode_www_form(data)
        token = Digest::MD5.hexdigest enc_data[9..34]
        data[:icognocheck] = token
        # puts "the token is #{data[:icognocheck]}"

        response = make_post(API_URL, data)

        @cookies = response.cookies
        clever_response = response.to_str.split(/[\r]+/)

        # see HTML encoding of foreign language characters
        clever_response[0] = clever_response[0].force_encoding('UTF-8')

        # add the log
        conversation << question
        # add response from cleverbot to conversation
        conversation << clever_response[0]

        # return the response
        clever_response[0]
      end

      def set_conversation
        unless conversation.empty?
          count = 1
          conversation.first(8).reverse_each do |line|
            count += 1
            data[('vText' + count.to_s).to_sym] = line
          end
        end
      end
    end

    module Cleverbot
      extend Discordrb::Commands::CommandContainer
      extend Discordrb::EventContainer

      clever_bot = RubyCleverbot.new

      command(:cb, description: 'Answers using cleverbot', min_args: 1, usage: 'cb <text>') do |event, *str|
        Thread.new do
          sleep 3
          event.respond(CGI.unescapeHTML(clever_bot.send_message(str.join ' ')))
        end
        nil
      end

      pm do |event|
        event.respond(CGI.unescapeHTML(clever_bot.send_message(event.content)).downcase)
      end

      mention do |event|
        event.respond(CGI.unescapeHTML(clever_bot.send_message(event.content)).downcase)
      end
    end
  end
end