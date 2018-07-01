require 'discordrb'
require 'mongoid'
require 'yaml'
require 'singleton'

require_relative 'src/models/Guild'
require_relative 'src/models/User'
require_relative 'src/Config'
require_relative 'src/Utils'

Config.load(File.join(__dir__, 'nepbot.yml'))
Mongoid.load!('mongoid.yml', :development)

require_relative 'src/commands/Bot'
require_relative 'src/commands/Guild'
require_relative 'src/commands/Moderation'
require_relative 'src/commands/Money'
require_relative 'src/commands/User'

bot = Config.bot

bot.message do |event|
  next if bot.profile.id == event.message.author.id
  user = User.where(user_id: event.message.author.id).first_or_create!
  guild = Guild.where(guild_id: event.server.id).first

  next if guild and filter(guild, user, event)

  delta = Time.now - user.last_message_time
  delta = 0 if delta < 10
  delta = 3600 if delta > 3600
  
  if delta > 0
    x = delta*Math.sqrt(event.message.text.length)/20 + 10
    user.last_message_time = Time.now
    user.balance += 4 * (Math.sqrt(x)/Math.log10(x)) - 4 * 3.16
    user.save
  end
end

bot.message_edit do |event|
  next if bot.profile.id == event.message.author.id
  user = User.where(user_id: event.message.author.id).first_or_create!
  guild = Guild.where(guild_id: event.server.id).first

  next if guild and filter(guild, user, event)
end

bot.member_join do |event|
  guild = Guild.where(guild_id: event.server.id).first
  if guild
    log(guild, event, 'Join', '<@' + event.user.id.to_s + '>', event.user)
    if guild.role_auto
      event.user.add_role(guild.role_auto)
    end
  end
end

bot.member_leave do |event|
  guild = Guild.where(guild_id: event.server.id).first
  if guild
    log(guild, event, 'Part', '<@' + event.user.id.to_s + '>', event.user)
  end
end

bot.run