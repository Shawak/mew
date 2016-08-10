module Mew
  class Config

    attr_accessor :discord_token, :owner_id, :permissions, :prefix,
                  :codingame_email, :codingame_password

    def initialize(file, skip)
      config = load file
      setup(file) if config == {} && !skip
      export config
    end

    def setup(file)
      puts 'No config file found, running the setup..'

      puts 'Discord Token: '
      @discord_token = gets.chomp

      puts 'OwnerID (Enter for 212564055901077505): '
      @owner_id = gets.chomp
      @owner_id = 212564055901077505 if @owner_id.empty?

      puts 'Permissions Code (Enter for 66321471): '
      @permissions = gets.chomp
      @permissions = 66321471 if @permissions.empty?

      puts 'Prefix (Enter for "."): '
      @prefix = gets.chomp
      @prefix = '.' if @prefix.empty?

      @codingame_email = ''
      @codingame_password = ''

      puts 'Setup complete!'
      save file
    end

    def export(config)
      config.keys.each do |key|
        self.class.send(:define_method, key) do
          config[key]
        end
      end
    end

    def variables_to_hash
      hash = {}
      instance_variables.each { |key|
        hash[key[1..key.size]] = instance_variable_get key
      }
      hash
    end

    def save(file)
      json = JSON.pretty_generate(variables_to_hash)
      File.open(file, 'w') do |f|
        f.write json
      end
    end

    def load(file)
      File.exist?(file) ? JSON.parse(File.read(file)) : {}
    end

  end
end