class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]
  before_action :client

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    Apis::LineBotClient.create_message(body, @client, signature)
    head :ok
  end

  private

  def client
    @client ||= Apis::LineBotClient.client
  end
end
