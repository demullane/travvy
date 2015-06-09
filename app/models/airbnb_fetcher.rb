require 'mechanize'

class AirbnbFetcher

  def initialize
    @page = Mechanize.new.get('https://www.airbnb.com')
  end

  def search_airbnb(location_input, arrival_date, departure_date, guest_count)
    form = @page.forms[3]
      form['location'] = "#{location_input[:city]}, #{location_input[:state]}, #{location_input[:zipcode]}" #city, state, zipcode
      form['checkin'] = arrival_date
      form['checkout'] = departure_date
      form['guests'] = self.guest_count_converter(guest_count)
    @page = form.submit
  end

  def airbnb_search_query(location_input, arrival_date, departure_date, guest_count)
    @location_input = location_input
    if !defined?(page_count)
      self.search_airbnb(@location_input, arrival_date, departure_date, guest_count)
      page_count = 1
      @airbnb_results = []
      self.airbnb_pretty_results
      results_count = @page.search('.results_count').text.strip.split(' ')[4].to_i
      origin_query = @page.uri.to_s
      origin_query.slice! '&source=bb'
      p ('ORIGIN QUERY: ') + origin_query
    end
    while results_count > (page_count * 18) && (page_count * 18) <= 54
      page_count += 1
      next_page = origin_query + "&page=#{page_count}"
      @page = Mechanize.new.get(next_page)
      self.airbnb_pretty_results
      p "PAGE #{page_count}: " + next_page
    end
    return true, @airbnb_results.uniq { |listing| [listing[:latitude], listing[:longitude]] }
  end

  def airbnb_pretty_results
    titles = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-name']}
    links = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-url']}
    prices = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-price']}
    imgs = @page.search("//span[contains(concat(' ', @class, ' '),' wish_list_button ')]").collect {|node| node['data-img']}
    location_description = @page.search("//span[contains(concat(' ', @class, ' '),' wish_list_button ')]").collect {|node| node['data-address']}
    latitudes = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-lat']}
    longitudes = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-lng']}

    links = links.map do |link|
      add_on = "https://www.airbnb.com"
      add_on << link
      link = add_on
    end

    prices = prices.map do |price|
      number = price.scan(/\d/).join('')
      price = "$" + number
    end

    titles.each_with_index do |val, index|
      @airbnb_results << {:title => val.split.map(&:capitalize).join(' '), :link => links[index], :price => prices[index], :image => imgs[index], :location_description => location_description[index], :latitude => latitudes[index], :longitude => longitudes[index]}
    end

    @airbnb_results.each do |listing|
      listing[:distance] = Geocoder::Calculations.distance_between([listing[:latitude],listing[:longitude]], [@location_input[:latitude],@location_input[:longitude]]).round(1)
    end
  end

  def guest_count_converter(guest_count)
    if guest_count == 1
      return '1 Guest'
    else
      return (guest_count.to_s + ' Guests')
    end
  end

end
