class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]
  before_action :client

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    validate_signature(body, signature)
    Apis::LineBotClient.create_message(body, client)
    head :ok
  end

  private

  def validate_signature(body, signature)
    unless client.validate_signature(body, signature)
      # ここで例外処理
      error 400 do 'Bad Request' end
    end
  end

  def client
    @client ||= Apis::LineBotClient.client
  end
end
