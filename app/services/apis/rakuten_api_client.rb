class Apis::RakutenApiClient
  BASE_URL = 'https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20170426'.freeze

  def search_and_create_message(keyword)
    conn = Faraday.new(
      url: BASE_URL,
      params: { 'applicationId': ENV['RAKUTEN_APPID'], 'hits': 5, 'keyword': keyword, 'formatVersion': 2 }
    )
    response = JSON.parse(conn.get.body)
    text = ''
    if response.key?('error')
      text = "この検索条件に該当する宿泊施設が見つかりませんでした。\n条件を変えて再検索してください。"
    else
      response['hotels'].each do |hotel|
        text << hotel[0]['hotelBasicInfo']['hotelName'] + "\n" + hotel[0]['hotelBasicInfo']['hotelInformationUrl'] + "\n" + "\n"
      end
    end
    {
      type: 'text',
      text: text
    }
  end

  class << self
    def client
      Apis::RakutenApiClient.new
    end
  end
end
