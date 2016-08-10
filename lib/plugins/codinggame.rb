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
            nil
          end
        end

        def users
          response = self.class.post('/services/ClashOfCodeRemoteService/findClashByHandle',
                                     :verify => false,
                                     headers: {'Cookie' => @cookie.to_cookie_string},
                                     :body => "[\"#{@handle}\"]")

          if response.success? && response['success']
            ret = []
            response['success']['players'].each do |p|
              ret.push p['codingamerNickname']
            end
            ret
          else
            nil
          end
        end

        def start
          response = self.class.post('/services/ClashOfCodeRemoteService/startClashByHandle',
                                     :verify => false,
                                     headers: {'Cookie' => @cookie.to_cookie_string},
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
      client.login

      lobby = nil
      response = nil

      command(:clash,
              description: 'Generates a codingame lobby link',
              usage: 'clash (public|private|start)') do |event, param|

        param = 'private' if param == nil

        if lobby.nil? && param == 'private'
          lobby = client.create
          response = event.respond 'Lobby: ' + lobby <<
                                       "\njoin folks!"
          temp = lobby
          Thread.new do
            while lobby == temp
              response.edit 'Lobby: ' + lobby <<
                                "\nPlayers: " + client.users.join(', ')
              sleep 5
            end
          end
          Thread.new do
            sleep 60 * 4.9
            if lobby == temp
              lobby = nil
              response.edit 'Lobby: closed!'
            end
          end
        elsif !lobby.nil? && param == 'start'
          client.start
          (1..3).each do |i|
            response.edit 'Lobby: ' + lobby <<
                              "\n> starting the lobby in .. #{4-i}"
            sleep 1
          end
          response.edit 'Lobby: started!'
          lobby = nil
        end
        nil
      end
    end
  end
end