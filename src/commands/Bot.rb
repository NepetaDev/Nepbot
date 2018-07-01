bot = Config.bot

bot.command :eval do |event|
  next if not can(event, 'bot')

  text = event.message.text
  text.gsub! '& eval', ''
  text.gsub! '```ruby', ''
  text.gsub! '```', ''

  begin
    ret = eval text
    "```\n" + ret.to_s + "\n```"
  rescue Exception => exc
    event.message.react('👎')
    "```\n" + exc.message + "\n```"
  end
end

bot.command :b_set do |event, *args|
  next if not can(event, 'bot')
  if event.message.mentions.length == 1 and (is_float?(args[1]) or args[1] == 'inf' or args[1] == '∞')
    target = User.where(user_id: event.message.mentions[0].id).first_or_create!
    if is_float?(args[1])
      target.balance = BigDecimal(args[1])
      target.infinite_balance = false
      puts "saved " + args[1]
    elsif args[1] == 'inf' or args[1] == '∞'
      target.infinite_balance = true
      puts "saved"
    end
    target.save

    event.message.react('👌')
  else
    event.message.react('👎')
  end
end

bot.command :g_config do |event|
  next if not can(event, 'bot')
  guild = Guild.where(guild_id: event.server.id).first_or_create!
  "```\n" + YAML::dump(guild) + "\n```"
end

bot.command :about do |event|
  "```\nNepbot 0.1\n```"
end