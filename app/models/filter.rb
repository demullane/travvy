class Filter

  def distance(results)
    return results.sort! {|a,b| a[:distance] <=> b[:distance]}
  end

  def price(results)
    return results.sort! {|a,b| a[:price][1..-1].to_i <=> b[:price][1..-1].to_i}
  end

end
