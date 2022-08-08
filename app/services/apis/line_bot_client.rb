class Apis::LineBotClient
  class << self
    def create_message(body, client)
      events = client.parse_events_from(body)
      events.each do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = Apis::RakutenApiClient.client.search_and_create_message(event.message['text'])
            client.reply_message(event['replyToken'], message)
          when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
            response = client.get_message_content(event.message['id'])
            tf = File.open("/tmp/#{SecureRandom.uuid}.jpg", 'w+b')
            tf.write(response.body)
          end
        end
      end
    end

    def client
      Line::Bot::Client.new do |config|
        config.channel_secret = ENV['LINE_CHANNEL_SECRET']
        config.channel_token = ENV['LINE_CHANNEL_TOKEN']
      end
    end
  end
end
