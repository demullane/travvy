class HotelFetcher

  def initialize
    @hotel_search = Faraday.new(:url => 'http://api.ean.com/ean-services/rs/hotel/v3/list?') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def search_hotels
    response = @hotel_search.get do |req|
      req.params['apiKey'] = ENV['EXPEDIA_KEY']
      req.params['cid'] = 55505 # ENV['CID']- testing
      req.params['minorRev'] = 4
      req.params['locale'] = 'en_US'
      req.params['currencyCode'] = 'USD'
      req.params['arrivalDate'] = '05/21/2015'
      req.params['departureDate'] = '05/22/2015'
      req.params['numberOfResults'] = 18
      req.params['room1'] = 2
      req.params['city'] = 'Denver'
      req.params['stateProvinceCode'] = 'CO'
      req.params['countryCode'] = 'US'
    end
    JSON.parse(response.body)
  end

  def hotel_pretty_results
    data = self.search_hotels
    @hotels = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['name']}
    return @hotels
  end

end
