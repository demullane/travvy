require 'geocoder'

class Search

  def decipher_location_input_params(location)
    search_obj = Geocoder.search(location)
    country = search_obj[0].address.split(',').map{|piece| piece.strip}.last
    if country == 'USA'
      location_data = {}
      location_data[:latitude] = search_obj[0].latitude
      location_data[:longitude] = search_obj[0].longitude
      location_data[:address] = search_obj[0].address
      location_data[:city] = search_obj[0].city
      location_data[:state] = search_obj[0].state
      location_data[:zipcode] = search_obj[0].postal_code

      if !location_data[:city]
        return self.decipher_location_input_params(location_data[:latitude].to_s + "," + location_data[:longitude].to_s)
      end
    else
      return false, 'Please enter a US location.'
    end

    return true, location_data
  end

end
