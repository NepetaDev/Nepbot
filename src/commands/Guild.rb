bot = Config.bot

bot.command :g_fw do |event, *args|
  next if not can(event)
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  guild.forbidden_words.to_s
end

bot.command :g_fw_add do |event, *args|
  next if not can(event)
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  guild.forbidden_words += args
  guild.save

  event.message.react('👌')
end

bot.command :g_fw_del do |event, *args|
  next if not can(event)
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  guild.forbidden_words -= args
  guild.save

  event.message.react('👌')
end

bot.command :g_roles do |event|
  next if not can(event)
end

bot.command :g_jr_add do |event, *args|
  next if not can(event)
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  roles = args.map { |arg| role_id(event, arg) }
  guild.joinable_roles += roles.select { |id| id > 0 }
  guild.save
  
  event.message.react('👌')
end

bot.command :g_jr_del do |event, *args|
  next if not can(event)
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  roles = args.map { |arg| role_id(event, arg) }
  guild.joinable_roles -= roles.select { |id| id > 0 }
  guild.save
  
  event.message.react('👌')
end

bot.command :g_jr do |event, *args|
  next if not can(event)
end

bot.command :g_role_auto do |event, *args|
  next if not can(event)
  if not args[0]
    event.message.react('👎')
    next
  end

  guild = Guild.where(guild_id: event.server.id).first_or_create!
  guild.role_auto = role_id(event, args[0])
  guild.save
  event.message.react('👌')
end

bot.command :g_role_member do |event, *args|
  next if not can(event)
  if not args[0]
    event.message.react('👎')
    next
  end
  
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  guild.role_member = role_id(event, args[0])
  guild.save
  event.message.react('👌')
end

bot.command :g_log do |event, *args|
  next if not can(event)
  channel = event.server.channels.select { |channel| channel.id == args[0][2..-2].to_i }[0]
  guild = Guild.where(guild_id: event.server.id).first_or_create!

  id = 0
  id = channel.id if channel
  guild.log_channel_id = id
  guild.save

  event.message.react('👌')
end