bot = Config.bot

bot.command :join do |event, *args|
  if args.length == 0
    event.message.react('👎')
    next
  end
  guild = Guild.where(guild_id: event.server.id).first
  if not guild or guild.joinable_roles.length == 0 or (guild.role_member > 0 and not event.user.role?(guild.role_member))
    event.message.react('👎')
    next
  end
  id = role_id(event, args[0])
  if id == 0 or not guild.joinable_roles.include? id
    event.message.react('👎')
    next
  end

  event.user.add_role(id)
  event.message.react('👌')
end

bot.command :leave do |event, *args|
  if args.length == 0
    event.message.react('👎')
    next
  end
  guild = Guild.where(guild_id: event.server.id).first
  if not guild or guild.joinable_roles.length == 0 or (guild.role_member > 0 and not event.user.role?(guild.role_member))
    event.message.react('👎')
    next
  end
  id = role_id(event, args[0])
  if id == 0 or not guild.joinable_roles.include? id
    event.message.react('👎')
    next
  end

  event.user.remove_role(id)
  event.message.react('👌')
end