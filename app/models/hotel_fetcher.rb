class HotelFetcher

  def initialize
    @hotel_search = Faraday.new(:url => 'http://api.ean.com/ean-services/rs/hotel/v3/') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def search_hotels(location_input, arrival_date, departure_date, guest_count)
    response = @hotel_search.get do |req|
      req.url('list?')
      req.params['apiKey'] = ENV['EXPEDIA_KEY']
      req.params['cid'] = 55505
      req.params['minorRev'] = 4
      req.params['locale'] = 'en_US'
      req.params['currencyCode'] = 'USD'
      req.params['arrivalDate'] = arrival_date #checkin variable
      req.params['departureDate'] = departure_date #checkout variable
      req.params['numberOfResults'] = 70 #1-200
      req.params['room1'] = guest_count #adult count variable
      req.params['destinationString'] = "#{location_input[:city]}, #{location_input[:state]}, #{location_input[:zipcode]}" #city, state, zipcode
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

  def hotel_pretty_results(location_input, arrival_date, departure_date, guest_count)
    data = self.search_hotels(location_input, arrival_date, departure_date, guest_count)['HotelListResponse']['HotelList']['HotelSummary']
    titles = data.map{ |hotel| hotel['name']}
    hotel_ids = data.map{ |hotel| hotel['hotelId']}
    room_type_codes = data.map{ |hotel| hotel['RoomRateDetailsList']['RoomRateDetails']['roomTypeCode']}
    prices = data.map{ |hotel| hotel['RoomRateDetailsList']['RoomRateDetails']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate']['@rate']}
    location_descriptions = data.map{ |hotel| hotel['locationDescription']}
    latitudes = data.map{ |hotel| hotel['latitude']}
    longitudes = data.map{ |hotel| hotel['longitude']}

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

      # replace &amp; and &apos; substrings with corresponding characters
      titles[index].sub! ' &amp;', ' &'
      titles[index].sub! '&amp;', '&'
      titles[index].sub! '&apos;', '\''
      location_descriptions[index].sub! ' &amp;', ' &'
      location_descriptions[index].sub! '&amp;', '&'
      location_descriptions[index].sub! '&apos;', '\''

      extra_info = self.extra_info(val)
      room_types = extra_info['HotelInformationResponse']['RoomTypes']
      room_type_count = room_types['@size'].to_i
      room_type = room_types['RoomType']
      if room_type_count == 1
        if room_type['@roomCode'].to_s == room_type_codes[index].to_s
          @room_amenities = room_type['roomAmenities']['RoomAmenity']
        end
      else
        room_type.each do |type|
          if type['@roomCode'].to_s == room_type_codes[index].to_s
            @room_amenities = type['roomAmenities']['RoomAmenity']
          end
        end
      end
      hotel_amentities = extra_info['HotelInformationResponse']['PropertyAmenities']['PropertyAmenity']
      # imgs = extra_info['HotelInformationResponse']['HotelImages']['HotelImage']

      #create array of hashes with info for each hotel listing
      hotel_results << {:title => titles[index], :link => links[index], :price => prices[index], :location_description => location_descriptions[index], :latitude => latitudes[index], :longitude => longitudes[index], :hotel_amenities => hotel_amentities, :room_amenities => @room_amenities}
    end
    hotel_results.each do |listing|
      listing[:distance] = Geocoder::Calculations.distance_between([listing[:latitude],listing[:longitude]], [location_input[:latitude],location_input[:longitude]]).round(1)
    end
    hotel_results.sort! {|a,b| a[:distance] <=> b[:distance]}

    return hotel_results
  end

end
