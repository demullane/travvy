class HotelFetcher

  def initialize
    @hotel_search = Faraday.new(:url => 'http://api.ean.com/ean-services/rs/hotel/v3/list?') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def hotel_finder
    @response = @hotel_search.get do |req|
      req.params['apiKey'] = ENV['EXPEDIA_KEY']
      req.params['cid'] = 55505
      req.params['minorRev'] = 4
      req.params['locale'] = 'en_US'
      req.params['currencyCode'] = 'USD'
      req.params['city'] = 'Seattle'
      req.params['stateProvinceCode']
      req.params['countryCode'] = 'US'
      req.params['output'] = 'json'
    end
    JSON.parse(@response.body)
  end

end
