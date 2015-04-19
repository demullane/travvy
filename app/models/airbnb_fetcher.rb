require 'mechanize'

class AirbnbFetcher

  def initialize
    @page = Mechanize.new.get('https://www.airbnb.com')
  end

  def search_airbnb #(location, checkin, checkout, guests)
      form = @page.forms[3]
        form['location'] = 'Denver, CO, United States'
        form['checkin'] = '04/21/2015'
        form['checkout'] = '04/22/2015'
        form['guests'] = '1 Guest'
      @page = form.submit
  end

  def pretty_results #(location, checkin, checkout, guests)
    self.search_airbnb #(location, checkin, checkout, guests)
    @titles = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-name']}
    @links = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-url']}
    @prices = @page.search("//div[contains(concat(' ', @class, ' '),' listing ')]").collect {|node| node['data-price']}
    @imgs = @page.search("//span[contains(concat(' ', @class, ' '),' wish_list_button ')]").collect {|node| node['data-img']}
    @addresses = @page.search("//span[contains(concat(' ', @class, ' '),' wish_list_button ')]").collect {|node| node['data-address']}

    @links = @links.map do |link|
      add_on = "https://www.airbnb.com"
      add_on << link
      link = add_on
    end

    @results = []
    @titles.each_with_index do |val, index|
        @results << {:title => val.split.map(&:capitalize).join(' '), :link => @links[index], :price => @prices[index], :image => @imgs[index], :address => @addresses[index]}
    end

    return @results
  end

end