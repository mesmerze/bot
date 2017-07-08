require 'telegram/bot'
require './lib.rb'
token = "fff"

def mapping_results(data)
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

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
  case message
  when Telegram::Bot::Types::InlineQuery
    case message.query
    when ''
      results = mapping_results(@categories)
    bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when 'rubizza'
      results = mapping_results(@rubizzas)
    bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when 'ruby'
      results = mapping_results(@rubies)
    bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when 'stuff'
      results = mapping_results(@stuff)
    bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    end
  when Telegram::Bot::Types::Message
    case message.text
    when '/start'
      bot.api.sendVideo(chat_id: message.chat.id, video: "http://coub.com/view/uxngm")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.last_name}")
    when '/rand'
      bot.api.sendVideo(chat_id: message.chat.id, video: @top_gear[rand(8)])
    when '/commands'
      bot.api.send_message(chat_id: message.chat.id, text:
      'Commands: /start, /stop, /rand, /commands')
    else
      if message.photo && message.sticker.nil?
        bot.api.sendVideo(chat_id: message.chat.id, video:
        'http://coub.com/view/1zv8z')
      end
      if message.sticker
        bot.api.send_sticker(chat_id: message.chat.id, sticker:
        'CAADBAADEQAD2uDCCfMwhYb-87y4Ag')
      end
      bot.api.send_message(chat_id: message.chat.id, text:
      'Commands: /start, /stop, /rand, /commands')
    end
  end
  end
end
