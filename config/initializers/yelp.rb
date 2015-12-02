# client = Yelp::Client.new({ consumer_key: "Z0MtEf2s45VhWBxv7nR6-A",
#                                 consumer_secret: "NH5hl8yEwduDzZr9dgBZvEeQUtY",
#                                 token: "P47c2BKw82S_-bF-RzqpY4moxzDF26FC",
#                                 token_secret: "3y7xIZ74bO0-PdiKXj9UVp3uD7I"
#                               })

require 'yelp'

Yelp.client.configure do |config|
  config.consumer_key = "Z0MtEf2s45VhWBxv7nR6-A"
  config.consumer_secret = "NH5hl8yEwduDzZr9dgBZvEeQUtY"
  config.token = "P47c2BKw82S_-bF-RzqpY4moxzDF26FC"
  config.token_secret = "3y7xIZ74bO0-PdiKXj9UVp3uD7I"
end