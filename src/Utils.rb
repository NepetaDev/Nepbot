def user_can(member, scope = '')
  # I should add some other checks in here I guess but for now I don't need this much control.
  if member.id == Config.owner
    true
  elsif scope != 'bot' and (member.id == Config.owner or member.owner? or member.permission?(:administrator))
    true
  else
    false
  end
end

def is_float?(fl)
  fl =~ /(^(\-)?(\d+)(\.)?(\d+)?)|(^(\-)?(\d+)?(\.)(\d+))/
end

def is_integer?(i)
  i =~ /^(\d)+$/
end

def clean_text(text)
  text.gsub(/[\u0080-\uffff]/, '').downcase
end

def flatten_embed_fields(fields)
  fields.inject('') do |str, field|
    str + field.name + field.value
  end
end

def flatten_embeds(embeds)
  embeds.inject('') do |str, embed|
    str += embed.title if embed.respond_to? :title and embed.title
    if embed.respond_to? :author and embed.author
      str += embed.author.name if embed.author.respond_to? :name and embed.author.name
      str += embed.author.url if embed.author.respond_to? :url and embed.author.url
    end
    if embed.respond_to? :fields and embed.fields
      str += flatten_embed_fields(embed.fields)
    end
    str += embed.description if embed.respond_to? :description and embed.description
    str += embed.footer.text if embed.respond_to? :footer and embed.footer and embed.footer.text
    str
  end
end

def role_id(event, name)
  roles = event.server.roles.select { |role| role.name.downcase == name.downcase or role.id == name }
  if roles.length > 0
    roles[0].id
  else
    0
  end
end

def log(guild, event, title, text, user = nil)
  channel = event.server.channels.select { |channel| channel.id == guild.log_channel_id }[0]

  if not channel
    guild.log_channel_id = 0
    guild.save
  else
    channel.send_embed do |embed|
      embed.title = title
      embed.description = text
      embed.colour = 0xFF0000
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: user.username, icon_url: user.avatar_url) if user
      embed.timestamp = Time.now
    end
  end
end

def filter(guild, user, event)
  username = event.message.author.username
  username = event.message.author.nick if event.message.author.nick
  text = clean_text(username + ' ' + event.message.text + ' ' + flatten_embeds(event.message.embeds))

  if guild.forbidden_words.any? { |e| text.include? e } and not user_can(event.message.author)
    event.message.delete
    if guild.log_channel_id != 0
      log(guild, event, 'Message removed', event.message.text, event.message.author)
    end

    true
  end

  false
end

def can(event, scope = '')
  if user_can(event.message.author, scope)
    true
  else
    event.message.react('🖕')
    false
  end
end

def no_mentions(event)
  if event.message.mentions.length > 0
    false
  else
    event.message.react('👎')
    true
  end
end