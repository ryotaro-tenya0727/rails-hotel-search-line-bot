class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = File.open("/tmp/#{SecureRandom.uuid}.jpg", 'w+b')
          tf.write(response.body)
        end
      end
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def search_and_create_message(keyword)
    conn = Faraday.new(
      url: 'https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20170426',
      params: { 'applicationId': ENV['RAKUTEN_APPID'], 'hits': 5, 'keyword': keyword, 'formatVersion': 2 }
    )
  end
end
