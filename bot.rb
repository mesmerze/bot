require 'telegram/bot'
require './lib.rb'
require 'dotenv/load'
token = ENV['TOKEN']

def map_results(data)
  data.map do |arr|
    Telegram::Bot::Types::InlineQueryResultArticle.new(
      id: arr[0],
      title: arr[1],
      input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
        message_text: arr[2]
      )
    )
  end
end

def answer_inline(category, bot, message)
  results = map_results(category)
  bot.api.answer_inline_query(inline_query_id: message.id,
                              results: results)
end

def send_message(bot, message, message_text = "Bye, #{message.from.last_name}")
  bot.api.send_message(chat_id: message.chat.id,
                       text: message_text)
end

def send_video(bot, message, video)
  bot.api.sendVideo(chat_id: message.chat.id,
                    video: video)
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      case message.query
      when '' then answer_inline(CATEGS, bot, message)
      when 'rubizza' then answer_inline(RUBIZZAS, bot, message)
      when 'ruby' then answer_inline(RUBIES, bot, message)
      when 'stuff' then answer_inline(STUFF, bot, message)
      end
    when Telegram::Bot::Types::Message
      case message.text
      when '/start' then send_video(bot, message, COUBS.first)
      when '/stop' then send_message(bot, message)
      when '/rand' then send_video(bot, message, TOP_GEAR[rand(8)])
      when '/commands' then send_message(bot, message, COMMANDS)
      else
        send_video(bot, message, COUBS.last) if message.photo &&
                                                message.sticker.nil?
        if message.sticker
          bot.api.send_sticker(chat_id: message.chat.id, sticker: STICKER)
        end
        bot.api.send_message(chat_id: message.chat.id, text: COMMANDS)
      end
    end
  end
end
