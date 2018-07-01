bot = Config.bot

bot.command :kick do |event|
  next if not can(event)
  next if no_mentions(event)

  event.message.mentions.each do |member|
    event.server.kick(member)
  end

  event.message.react('👌')
end

bot.command :ban do |event|
  next if not can(event)
  next if no_mentions(event)
  
  event.message.mentions.each do |member|
    event.server.ban(member)
  end

  event.message.react('👌')
end

bot.command :mute do |event|
  next if not can(event)
  next if no_mentions(event)
  
  event.message.mentions.each do |member|
    deny = Discordrb::Permissions.new
    deny.can_send_messages = true
    event.message.channel.define_overwrite(member, nil, deny)
  end

  event.message.react('👌')
end

bot.command :unmute do |event|
  next if not can(event)
  next if no_mentions(event)
  
  event.message.mentions.each do |member|
    event.message.channel.delete_overwrite(member)
  end

  event.message.react('👌')
end

bot.command :purge do |event, *args|
  next if not can(event)

  amount = 25
  amount = args[0].to_i if is_integer?(args[0])
  
  messages = []

  if event.message.mentions.length > 0
    member_ids = event.message.mentions.map(&:id)
    messages = event.channel.history(amount).select { |m| member_ids.include?(m.author.id) }.map(&:id)
  else
    messages = event.channel.history_ids(amount)
  end

  if messages.size == 1
    event.channel.delete_message(messages.first)
  elsif messages.size > 1
    event.channel.delete_messages(messages)
  end

  event.message.react('👌')
end