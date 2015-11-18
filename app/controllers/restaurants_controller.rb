class RestaurantsController < ApplicationController

  def index
    if $error == "No Results"
      $error = "We couldn't find a restaurant matching that name, check the spelling and try again."
    end
  end

  def reviews
    $error = nil
    if params[:location]
      @city = params[:location]
      @response = Yelp.client.search( @city, { term: params[:term], limit: 5 })
      if @response.total == 0
        $error = "We couldn't find a restaurant matching that name, check the spelling and try again."
        redirect_to '/'
      end
    end

    @yelp_restaurant = Yelp.client.business(@response.businesses[0].id)

    yelp_url = @yelp_restaurant.url
    headers = {
          # "ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
          # "ACCEPT_ENCODING" => "gzip, deflate, sdch",
          # "ACCEPT_LANGUAGE" => "en-US,en;q=0.8",
          # "CONNECTION" => "keep-alive",
          # # "HOST"=>"http://www.yelp.com/",
          # "UPGRADE_INSECURE_REQUESTS"=>"1",
          # "USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36"
          }

    yelp = HTTParty.get(yelp_url, :headers=> headers)
    yelp_page = Nokogiri::HTML(yelp)
    yelp_reviews = yelp_page.css('div.review-content p').to_s.split('</p>')[0..2].map { |review| review.split("ang=\"en\">")[1] }
    # binding.pry
    @yelp_previews = yelp_reviews.map { |review| review[0..140] }
    @yelp_fulltext = yelp_reviews.map { |review| review[141..review.length-1] }

    @yelp_ratings = yelp_page.css('div.review--with-sidebar div.review-content i.star-img').to_s.split("title=\"")[1..3].map { |rating| rating.split(" star rating")[0] }
    @yelp_dates = yelp_page.css('div span.rating-qualifier').to_s.split("datePublished\" content=\"")[1..3].map { |date| date[0..9]}

    zomato_city_id = 89 #Toronto
    @zomato_restaurant = HTTParty.get('https://developers.zomato.com/api/v2.1/search?q=' + @yelp_restaurant.name.downcase.gsub(' ','+') + '&count=1&lat=' + @yelp_restaurant.location.coordinate.latitude.to_s + '&lon=' + @yelp_restaurant.location.coordinate.longitude.to_s, :headers => {'user_key' => @@ZOMATO_KEY})["restaurants"][0]["restaurant"]
    @zomato_url = @zomato_restaurant["url"]
    zomato = HTTParty.get(@zomato_url, :headers => headers)
    zomato_page = Nokogiri::HTML(zomato)
    zomato_content = zomato_page.css('div.rev-text')
    @zomato_ratings = zomato_content.to_s.split("label=\"Rated ")[1..3].map{ |rating| rating[0..2]}
    @zomato_dates = date = zomato_page.xpath("//time").to_s.split("datetime=\"")[1..3].map { |date| date[0..9]}

    zomato_reviews_dirty = zomato_content.text.split("                                            ")[1..5]
    zomato_reviews = []
    zomato_reviews_dirty.each do |review|
      if (!review.include? "                    Rated") && (!review.include?("                \n                "))
        zomato_reviews << review
      end
    end
    @zomato_previews = zomato_reviews.map { |review| review[0..140] }
    @zomato_fulltext = zomato_reviews.map { |review| review[141..review.length-1] }

    # binding.pry
    search_name = @zomato_restaurant["name"].downcase
    if search_name.include? ' + '
      search_name.gsub!(' + ',' ')
    end

    if search_name.include? '&'
      search_name.gsub!('&','and')
    end

    search_name.gsub!(' ','-')

    open_table_url = "http://www.opentable.com/" + search_name
    open_table = HTTParty.get(open_table_url, :headers=> headers)
    open_table_page = Nokogiri::HTML(open_table)
    if !open_table_page.text.include? "We're sorry, but the page you requested could not be found."
      open_table_reviews = open_table_page.css('#reviews-page p').to_s.split('</p>')[0..2]
      @open_table_previews = open_table_reviews.map { |review| review[0..140] }
      @open_table_fulltext = open_table_reviews.map { |review| review[141..review.length-1] }
      @open_table_ratings = open_table_page.css('#reviews-results div.all-stars').to_s.split("title=\"")[1..3].map {|s| s[0].split("\" class")[0]}
      @open_table_dates = open_table_page.css('#reviews-results div.review-meta > span').to_s.split("color-light\">")[1..3].map { |date| date.split("<")[0] }
    end

    bookenda_url = 'https://www.bookenda.com/' + search_name
    bookenda = HTTParty.get(bookenda_url, :headers=> headers)
    bookenda_page = Nokogiri::HTML(bookenda)
        # binding.pry
    if !bookenda_page.text.include? ("We're sorry, but the page you requested could not be found.")
      bookenda_reviews = bookenda_page.css('div#containerReview div.row p').to_s.split("itemprop=\"description\">")[1..3].map { |review| review.split("</p>")[0] }
      @bookenda_previews = bookenda_reviews.map { |review| review[0..140] }
      @bookenda_fulltext = bookenda_reviews.map { |review| review[141..review.length-1] }
      @bookenda_ratings = bookenda_page.css('div#containerReview div.row div.score meta').to_s.split("itemprop=\"ratingValue\" content=\"")[1..3].map { |rating| rating[0..3] }
      @bookenda_dates = bookenda_page.css('div#containerReview div.row small').to_s.split("content=\"")[1..3].map { |date| date[0..9] }
    end
  end

  def show

  end

  def new

  end

  def edit
    # @yelp_restaurant = Restaurant.find(params[:id])
  end

  def create
    # @restaurant = Restaurant.new(restaurant_params)

    # if @restaurant.save
    #   redirect_to restaurants_path
    # else
    #   render :new
    # end
  end

  def update
    # @restaurant = Restaurant.find(params[:id])

    # if @restaurant.update_attributes(restaurant_params)
    #   redirect_to restaurant_path(@restaurant)
    # else
    #   render :edit
    # end
  end

  def destroy
    # @restaurant = Restaurant.find(restaurant[:id])
    # @restaurant.destroy
    # redirect_to restaurants_path
  end

  protected

  def restaurant_params
    params.require(:restaurant).permit(
      :name, :address, :price_range, :cuisine, :city
      )
  end

end
