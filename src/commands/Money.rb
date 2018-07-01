bot = Config.bot

bot.message(start_with: '$') do |event|
  split = event.message.text.split(' ')
  next if split[0] != '$'
  user = User.where(user_id: event.message.author.id).first
  next if not user

  if event.message.mentions.length == 1
    case split.length
    when 2
      target = User.where(user_id: event.message.mentions[0].id).first_or_create!

      balance = sprintf('%.2f', target.balance)
      if target.infinite_balance
        balance = '∞'
      end

      event.channel.send_embed do |embed|
        embed.title = 'Balance'
        embed.description = Config.currency + ' ' + balance
        embed.colour = 0x0BB797
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.mentions[0].username, icon_url: event.message.mentions[0].avatar_url)
        embed.timestamp = Time.now
      end

      next
    when 3
      amount = 0
      if is_float?(split[1])
        amount = BigDecimal(split[1])
      elsif is_float?(split[2])
        amount = BigDecimal(split[2])
      end

      if (amount > 0 and (user.balance >= amount or user.infinite_balance)) or user_can(event.message.author, 'bot')
        target = User.where(user_id: event.message.mentions[0].id).first_or_create!
        
        user.balance -= amount
        user.save
        
        target.balance += amount
        target.save

        event.channel.send_embed do |embed|
          embed.title = 'Transaction'
          embed.add_field(name: 'From', value: '<@' + event.message.author.id.to_s + '>', inline: true)
          embed.add_field(name: 'To', value: '<@' + event.message.mentions[0].id.to_s + '>', inline: true)
          embed.add_field(name: 'Amount', value: Config.currency + ' ' + sprintf('%.2f', amount), inline: true)
          embed.colour = 0x0C4EB7
          embed.timestamp = Time.now
        end

        next
      end
    end
  else
    case split.length
    when 1
      balance = sprintf('%.2f', user.balance)
      if user.infinite_balance
        balance = '∞'
      end

      event.channel.send_embed do |embed|
        embed.title = 'Balance'
        embed.description = Config.currency + ' ' + balance
        embed.colour = 0x0BB797
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.author.username, icon_url: event.message.author.avatar_url)
        embed.timestamp = Time.now
      end

      next
    when 4
      case split[1]
      when 'flip'
        if is_float?(split[2]) and split[2].to_i > 0 and (user.balance >= split[2].to_i or user.infinite_balance) and (split[3] == 'tails' or split[3] == 'heads')
          result = 'tails'
          result = 'heads' if Random.rand(2) == 1
          message = 'won'
          amount = BigDecimal(split[2].to_i)
          if split[3] == result
            user.balance += amount
          else
            message = 'lost'
            user.balance -= amount
          end
          user.save
          event.channel.send_embed do |embed|
            embed.title = 'Coin flip'
            embed.description = '**Result: **' + result + "\n**You've " + message + ':** ' + Config.currency + ' ' + split[2]
            embed.colour = 0x0BB797
            embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.message.author.username, icon_url: event.message.author.avatar_url)
            embed.timestamp = Time.now
          end
          next
        end
      end
    end
  end

  event.message.react('👎')
end