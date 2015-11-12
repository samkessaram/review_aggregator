yelp_page.css('.review-list p').to_s.split("<p itemprop=\"description\" lang=\"en\">").each {|x| x.split("</p>") }


test.each { |x| !x.include?('<p>') ? arr << x.split("</p>")[0] : x = nil }

yelp_dates.map { |date| date = date[0..9]}

@zomato_restaurant_id = HTTParty.get('https://developers.zomato.com/api/v2.1/search?q=' + @restaurant.name.downcase + '&count=1&lat=' + @restaurant.location.coordinate.latitude.to_s + '&lon=' + @restaurant.location.coordinate.longitude.to_s , :headers => {'user_key' => @@ZOMATO_KEY})
