module Config
  def self.load(file)
    @config = YAML::load_file(file)
    @bot = Discordrb::Commands::CommandBot.new token: self.token, prefix: '& '
  end

  def self.bot
    @bot
  end
    
  def self.owner
    @config['nepbot']['owner']
  end

  def self.currency
    @config['nepbot']['currency']
  end

  def self.token
    @config['nepbot']['token']
  end
end