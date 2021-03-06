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

      # :test => scrape_yelp
    }
  end

  def self.scrape_yelp
    # Append param to url
    y_url = @yelp_result.business.url + '?sort_by=date_desc'

    # Fetch page with HTTParty. Spoof headers
    y_raw = HTTParty.get(y_url, :headers=> {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"})

    # Parse with Nokogiri
    @y_parsed = Nokogiri::HTML(y_raw)

    # Scrape reviews
    y_reviews = @y_parsed.css('div.review-content p').to_s.split('</p>')[0..2].map { |review| review.split("ang=\"en\">")[1] }

    # Scrape ratings
    y_ratings = @y_parsed.css('div.review--with-sidebar div.review-content div.i-stars').to_s.split("title=\"")[1..3].map { |rating| rating.split(" star rating")[0].split('.0')[0] }

    # Scrape review date, parse date with Chronic gem
    @y_dates = @y_parsed.css('div.review-content span.rating-qualifier').to_s.split("qualifier\">\n")[1..3].map { |date| Chronic.parse(date[8..20]).strftime('%b %d, %Y')}

    # Return data object
    {dates: @y_dates, reviews: y_reviews, ratings: y_ratings, url: y_url}
  end

  def self.scrape_zomato

    # Get name to input in url
    z_name = @yelp_result.business.name.downcase

    # Terms to be eliminated, else results from API will be cluttered with mismatches
    generic_terms = ['lounge','restaurant','bar','grill','brasserie','bistro']

    generic_terms.each do |term|
      if z_name.include? term
        z_name.slice! term
      end
    end

    # Remove trailing whitespace
    z_name = z_name.strip

    z_city_id = 89 #Toronto

    # Call Zomato API with HTTParty
    @z_restaurant = HTTParty.get('https://developers.zomato.com/api/v2.1/search?q=' + z_name.gsub(' ','+') + '&count=3&lat=' + @yelp_result.business.location.coordinate.latitude.to_s + '&lon=' + @yelp_result.business.location.coordinate.longitude.to_s, :headers => {'user_key' => @@ZOMATO_KEY})["restaurants"][0]["restaurant"]
    z_url = @z_restaurant["url"]
    z_id = @z_restaurant["id"]

    # Initialize empty arrays to store data
    z_dates = []
    z_reviews = []
    z_ratings = []

    # Call API with restaurant ID, parse data
    reviews = HTTParty.get('https://developers.zomato.com/api/v2.1/reviews?res_id='+ @z_restaurant["id"] + '&count=3', :headers => {'user_key' => @@ZOMATO_KEY})["user_reviews"]
    reviews.each do |review|
      z_reviews.push(review["review"]["review_text"])
      z_dates.push(review["review"]["review_time_friendly"])
      z_ratings.push(review["review"]["rating"])
    end

    {dates: z_dates, reviews: z_reviews, ratings: z_ratings, url: z_url}
  end

  # Format search term to OpenTable specifications
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

    if (term.include? "'")
      term.slice!("'")
    end

    term
  end

  def self.scrape_opentable
    o_url = "http://www.opentable.com/" + term

    # Fetch page
    o = HTTParty.get(o_url, :headers=> {})

    @o_page = Nokogiri::HTML(o)

    # Check for errors
    oops_error = @o_page.text.include? "Oops! There was an error"
    not_found_error = @o_page.text.include? "We're sorry, but the page you requested could not be found."
    no_reviews_error = ( @o_page.css("#reviews-page").length == 0 )
    
    # If all good, proceed
    if !oops_error && !not_found_error && !no_reviews_error
      o_reviews = @o_page.css('#reviews-page p').to_s.split('</p>')[0..2].map { |r| r.gsub!('<p>','')}
      o_ratings = @o_page.css('#reviews-results div.all-stars').to_s.split("title=\"")[1..3].map {|s| s[0].split("\" class")[0]}
      @o_dates = @o_page.css('#reviews-results div.review-meta > span').to_s.split("Dined")[1..3].map { |date| date.split("<")[0] }

      @o_dates.map! do |date|
        # Strip out unnecessary word
        if date.include? 'on'
          date = date.split('on ')[1]
        end

        # Parse date with Chronic
        Chronic.parse(date).strftime('%b %d, %Y')
      end
    end

    {dates: @o_dates, reviews: o_reviews, ratings: o_ratings, url: o_url}
  end

  def self.scrape_bookenda
    # Need to implement some way to get around dynamically loaded content. 
    b_url = 'https://www.bookenda.com/' + term
    b = HTTParty.get(b_url, :headers=> {"USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36"
})
    @b_page = Nokogiri::HTML(b)
    
    # This is broken, reviews only load after a timeout
    no_reviews = (@b_page.css('div#containerReview div.row p').length == 0 ? true : false ) 

    not_found_error = @b_page.text.include? "We're sorry, but the page you requested could not be found."

    if !not_found_error && !no_reviews
      b_reviews = @b_page.css('div#containerReview div.row p').to_s.split("itemprop=\"description\">")[1..3].map { |review| review.split("</p>")[0] }
      b_ratings = @b_page.css('div#containerReview div.row div.score meta').to_s.split("itemprop=\"ratingValue\" content=\"")[1..3].map { |rating| rating[0..3] }
      b_dates = @b_page.css('div#containerReview div.row small').to_s.split("content=\"")[1..3].map { |date| Chronic.parse(date[0..9]).strftime('%b %d, %Y') }
    
      b_ratings.map! do |rating|
        if rating.include? '.00'
          rating = rating.split('.00')[0]
        else
          rating
        end
      end
    end

    {dates: b_dates, reviews: b_reviews, ratings: b_ratings, url: b_url}
  end

  def self.restaurant_info
    # Don't delete conditional below... There must be a reason this was written...

    # if @no_zomato
    #   name = @yelp_result.business.name
    # else
    #   name = @z_restaurant["name"]
    # end

    # Info to display in sidebar
    address = [@yelp_result.business.location.display_address[0], @yelp_result.business.location.display_address[1], @yelp_result.business.location.display_address[2]]

    {name: @yelp_result.business.name, address: address}
  end

end