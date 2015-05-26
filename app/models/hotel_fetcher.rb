class HotelFetcher

  def initialize
    @hotel_search = Faraday.new(:url => 'http://api.ean.com/ean-services/rs/hotel/v3/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def search_hotels
    response = @hotel_search.get do |req|
      req.url('list?')
      req.params['apiKey'] = ENV['EXPEDIA_KEY']
      req.params['cid'] = 55505
      req.params['minorRev'] = 4
      req.params['locale'] = 'en_US'
      req.params['currencyCode'] = 'USD'
      req.params['arrivalDate'] = '07/21/2015' #checkin variable
      req.params['departureDate'] = '07/22/2015' #checkout variable
      req.params['numberOfResults'] = 70 #1-200
      req.params['room1'] = 2 #adult count variable
      req.params['destinationString'] = 'Denver, CO' #full address from search.rb
    end
    JSON.parse(response.body)
  end

  def extra_info(hotel_id)
    response = @hotel_search.get do |req|
      req.url('info?')
      req.params['apiKey'] = ENV['EXPEDIA_KEY']
      req.params['cid'] = 55505
      req.params['minorRev'] = 4
      req.params['hotelId'] = hotel_id
      req.params['options'] = 'DEFAULT'
    end
    JSON.parse(response.body)
  end

  def hotel_pretty_results
    data = self.search_hotels
    data = data['HotelListResponse']['HotelList']['HotelSummary']
    titles = data.map{ |hotel| hotel['name']}
    hotel_ids = data.map{ |hotel| hotel['hotelId']}
    room_type_codes = data.map{ |hotel| hotel['RoomRateDetailsList']['RoomRateDetails']['roomTypeCode']}
    prices = data.map{ |hotel| hotel['RoomRateDetailsList']['RoomRateDetails']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate']['@rate']}
    location_descriptions = data.map{ |hotel| hotel['locationDescription']}
    latitudes = data.map{ |hotel| hotel['latitude']}
    longitudes = data.map{ |hotel| hotel['longitude']}
    proximities = data.map{ |hotel| hotel['proximityDistance']}

    links = []
    hotel_ids.each do |id|
      #build external link off of hotel id
      url = []
      url[0] = 'http://www.travelnow.com/templates/336616/hotels/' + id.to_s + '/overview?'
      url[1] = 'lang=en&currency=USD'
      url[2] = '&secureUrlFromDataBridge=https%3A%2F%2Fwww.travelnow.com'
      url[3] = '&requestVersion=V2'
      url[4] = '&checkin=07%2F21%2F2015' #checkin variable
      url[5] = '&checkout=07%2F22%2F2015' #checkout variable
      url[6] = '&creditCardInfo.needStartDate=true'
      url[7] = '&destination=Denver%2C+CO%2C+United+States' #city, state, country variables
      url[8] = '&filter.highPrice=2147483647'
      url[9] = '&filter.lowPrice=0'
      url[10] = '&roomsCount=1' #room count variable
      url[11] = '&rooms[0].adultsCount=1' #adult count variable
      url[12] = '&rooms[0].childrenCount=0' #child count variable?
      url[13] = '&standardCheckin=7%2F21%2F2015' #checkin variable
      url[14] = '&standardCheckout=7%2F22%2F2015' #checkout variable
      links << url.join('')
    end

    prices = prices.map do |price|
      price = '$' + price.to_i.round.to_s
    end

    hotel_results = []
    hotel_ids.each_with_index do |val, index|

      #pull extra_info data from hotel id
      extra_info = self.extra_info(val)
      extra_info['HotelInformationResponse']['RoomTypes']['RoomType'].each do |room_type|
        if room_type['@roomCode'].to_s == room_type_codes[index].to_s
          @room_amenities = room_type['roomAmenities']['RoomAmenity']
        end
      end
      hotel_amentities = extra_info['HotelInformationResponse']['PropertyAmenities']['PropertyAmenity']
      # imgs = extra_info['HotelInformationResponse']['HotelImages']['HotelImage']

      #create array of hashes with info for each hotel listing
      hotel_results << {:title => titles[index], :link => links[index], :price => prices[index], :location_description => location_descriptions[index], :latitude => latitudes[index], :longitude => longitudes[index], :hotel_amenities => hotel_amentities, :room_amenities => @room_amenities, :proximity => proximities[index]}
    end
    hotel_results.sort! {|a,b| a[:proximity] <=> b[:proximity]}

    return hotel_results
  end

end
