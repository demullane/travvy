require 'geocoder'

class Search

  def decipher_search_params(location)
    search_obj = Geocoder.search(location)
    country = search_obj[0].address.split(',').map{|piece| piece.strip}.last
    if country == 'USA'
      location_data = [{:latitude => nil, :longitude => nil}, {:address => nil}]
      location_data[0][:latitude] = search_obj[0].latitude
      location_data[0][:longitude] = search_obj[0].longitude
      location_data[1][:address] = search_obj[0].address
    else
      return false, 'Please enter a US location.'
    end

    return true, location_data
  end

end
