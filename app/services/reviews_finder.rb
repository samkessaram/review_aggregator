class ReviewsFinder

  def self.find_reviews(yelp_response)

    @yelp_result = Yelp.client.business(yelp_response.businesses[0].id)
    
    data = {
      :reviews => {
        :yelp => scrape_yelp,
        :zomato => scrape_zomato,
        :opentable => scrape_opentable,
        :bookenda => scrape_bookenda
      },
      :restaurant => restaurant_info
    }
  end

  def self.scrape_yelp
    y_url = @yelp_result.url
    y_raw = HTTParty.get(y_url, :headers=> {})
    y_parsed = Nokogiri::HTML(y_raw)
    y_reviews = y_parsed.css('div.review-content p').to_s.split('</p>')[0..2].map { |review| review.split("ang=\"en\">")[1] }
    y_ratings = y_parsed.css('div.review--with-sidebar div.review-content i.star-img').to_s.split("title=\"")[1..3].map { |rating| rating.split(" star rating")[0] }
    y_dates = y_parsed.css('div span.rating-qualifier').to_s.split("datePublished\" content=\"")[1..3].map { |date| date[0..9]}
  
    {dates: y_dates, reviews: y_reviews, ratings: y_ratings}
  end

  def self.scrape_zomato
    z_city_id = 89 #Toronto
    @z_restaurant = HTTParty.get('https://developers.zomato.com/api/v2.1/search?q=' + @yelp_result.name.downcase.gsub(' ','+') + '&count=1&lat=' + @yelp_result.location.coordinate.latitude.to_s + '&lon=' + @yelp_result.location.coordinate.longitude.to_s, :headers => {'user_key' => @@ZOMATO_KEY})["restaurants"][0]["restaurant"]
    z_url = @z_restaurant["url"]
    z = HTTParty.get(z_url, :headers => {})
    z_page = Nokogiri::HTML(z)
    z_content = z_page.css('div.rev-text')
    z_ratings = z_content.to_s.split("label=\"Rated ")[1..3].map{ |rating| rating[0..2]}
    z_dates = z_page.xpath("//time").to_s.split("datetime=\"")[1..3].map { |date| date[0..9]}

    z_reviews_dirty = z_content.text.split("                                            ")[1..5]
    z_reviews = []
    z_reviews_dirty.each do |review|
      if (!review.include? "                    Rated") && (!review.include?("                \n                "))
        z_reviews << review
      end
    end

    {dates: z_dates, reviews: z_reviews, ratings: z_ratings}
  end

  def self.term
    term = @z_restaurant["name"].downcase

    if (term.include? ' + ')
      term.gsub!(' + ',' ')
    end

    if (term.include? '&')
      term.gsub!('&','and')
    end
    
    if (term.include? ' ')
      term.gsub!(' ','-')
    end

    term
  end

  def self.scrape_opentable
    o_url = "http://www.opentable.com/" + term
    o = HTTParty.get(o_url, :headers=> {})
    o_page = Nokogiri::HTML(o)
    oops_error = o_page.text.include? "Oops! There was an error"
    not_found_error = o_page.text.include? "We're sorry, but the page you requested could not be found."

    if !oops_error && !not_found_error
      o_reviews = o_page.css('#reviews-page p').to_s.split('</p>')[0..2].map { |r| r.gsub!('<p>','')}
      o_ratings = o_page.css('#reviews-results div.all-stars').to_s.split("title=\"")[1..3].map {|s| s[0].split("\" class")[0]}
      o_dates = o_page.css('#reviews-results div.review-meta > span').to_s.split("color-light\">")[1..3].map { |date| date.split("<")[0] }
    end

    {dates: o_dates, reviews: o_reviews, ratings: o_ratings}
  end

  def self.scrape_bookenda
    b_url = 'https://www.bookenda.com/' + term
    b = HTTParty.get(b_url, :headers=> {})
    b_page = Nokogiri::HTML(b)
    if !b_page.text.include? ("We're sorry, but the page you requested could not be found.")
      b_reviews = b_page.css('div#containerReview div.row p').to_s.split("itemprop=\"description\">")[1..3].map { |review| review.split("</p>")[0] }
      b_ratings = b_page.css('div#containerReview div.row div.score meta').to_s.split("itemprop=\"ratingValue\" content=\"")[1..3].map { |rating| rating[0..3] }
      b_dates = b_page.css('div#containerReview div.row small').to_s.split("content=\"")[1..3].map { |date| date[0..9] }
    end

    {dates: b_dates, reviews: b_reviews, ratings: b_ratings}
  end

  def self.restaurant_info
    name = @z_restaurant["name"]
    address = [@yelp_result.location.display_address[0], @yelp_result.location.display_address[1], @yelp_result.location.display_address[2]]

    {name: name, address: address}
  end

end