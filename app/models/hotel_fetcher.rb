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
      req.params['cid'] = 55505
      req.params['minorRev'] = 4
      req.params['locale'] = 'en_US'
      req.params['currencyCode'] = 'USD'
      req.params['arrivalDate'] = '05/21/2015' #checkin variable
      req.params['departureDate'] = '05/22/2015' #checkout variable
      req.params['numberOfResults'] = 18
      req.params['room1'] = 2 #adult count variable
      req.params['city'] = 'Denver' #city variable
      req.params['stateProvinceCode'] = 'CO' #state variable
      req.params['countryCode'] = 'US' #country variable
    end
    JSON.parse(response.body)
  end

  def hotel_pretty_results
    data = self.search_hotels
    titles = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['name']}
    hotel_ids = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['hotelId']}
    prices = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['RoomRateDetailsList']['RoomRateDetails']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate']['@rate']}
    # imgs =
    location_descriptions = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['locationDescription']}
    latitudes = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['latitude']}
    longitudes = data['HotelListResponse']['HotelList']['HotelSummary'].map{ |hotel| hotel['longitude']}

    links = []
    hotel_ids.each do |id|
      url = []
      url[0] = 'http://www.travelnow.com/templates/336616/hotels/' + id.to_s + '/overview?'
      url[1] = 'lang=en&currency=USD'
      url[2] = '&secureUrlFromDataBridge=https%3A%2F%2Fwww.travelnow.com'
      url[3] = '&requestVersion=V2'
      url[4] = '&checkin=05%2F21%2F2015' #checkin variable
      url[5] = '&checkout=05%2F22%2F2015' #checkout variable
      url[6] = '&creditCardInfo.needStartDate=true'
      url[7] = '&destination=Denver%2C+CO%2C+United+States' #city, state, country variables
      url[8] = '&filter.highPrice=2147483647'
      url[9] = '&filter.lowPrice=0'
      url[10] = '&roomsCount=1' #room count variable
      url[11] = '&rooms[0].adultsCount=2' #adult count variable
      url[12] = '&rooms[0].childrenCount=0' #child count variable?
      url[13] = '&standardCheckin=5%2F21%2F2015' #checkin variable
      url[14] = '&standardCheckout=5%2F22%2F2015' #checkout variable
      links << url.join('')
    end

    hotel_results = []
    titles.each_with_index do |val, index|
      hotel_results << {:title => val, :link => links[index], :price => prices[index], :location_description => location_descriptions[index], :latitude => latitudes[index], :longitude => longitudes[index]}
    end

    return hotel_results
  end

end
