module Mew
  module Plugins
    # Creates and starts lobbies for codingame/clashofcode
    module Codinggame
      extend Discordrb::Commands::CommandContainer

      class Client
        include HTTParty

        base_uri 'https://www.codingame.com'

        def login
          response = self.class.post('/services/CodingamerRemoteService/loginSiteV2',
                                     :verify => false,
                                     :body => "[\"#{CONFIG.codingame_email}\",\"#{CONFIG.codingame_password}\",true]")

          if response.success? && response['success']
            @cookie = parse_cookie(response)
            @id = response['success']['user']['id']
            true
          else
            false
          end
        end

        def create
          response = self.class.post('/services/ClashOfCodeRemoteService/createPrivateClash',
                                     :verify => false,
                                     headers: {'Cookie' => @cookie.to_cookie_string},
                                     :body => "[#{@id},{\"SHORT\":true}]")

          if response.success? && response['success']
            #@cookie = parse_cookie(response)
            @handle = response['success']['publicHandle']
            @link = '/clashofcode/clash/' + response['success']['publicHandle']
            ShortURL.shorten 'https://anon.to/?' + self.class.base_uri + '/clashofcode/clash/' + response['success']['publicHandle'], :tinyurl
          else
            false
          end
        end

        def start
          response = self.class.post('/services/ClashOfCodeRemoteService/startClashByHandle',
                                     :verify => false,
                                     headers: {'Cookie' => @cookie.to_cookie_string},
                                     follow_redirects: true,
                                     :body => "[#{@id}, \"#{@handle}\"]")

          response.success? && response['success']
        end

        def parse_cookie(resp)
          cookie_hash = CookieHash.new
          resp.get_fields('Set-Cookie').each { |c| cookie_hash.add_cookies(c) }
          cookie_hash
        end
      end

      client = Client.new
      lobby = false

      command(:clash,
              description: 'Generates a codingame lobby link',
              usage: 'clash (public|private|start)') do |event, param|

        param = '' if param == nil

        if lobby === false && param == 'private' || param == ''
          client.login
          lobby = client.create

          t = lobby
          Thread.new do
            sleep 60 * 4.9
            if lobby == t
              event.respond 'codingame: lobby closed!'
              lobby = false
            end
          end

          'codingame: ' + lobby
        elsif lobby === false && param == 'public'
          'coingame: sorry i can\'t do this yet' # TODO
        else
          if param == 'start'
            if lobby
              client.start
              lobby = false
              event.respond 'codingame: starting the lobby!'
              (1..3).each do |i|
                sleep 1
                event.respond (4-i).to_s
              end
              nil
            else
              'codingame: there is no lobby to start!'
            end
          end
        end

      end
    end
  end
end