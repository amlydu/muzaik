class EchoNestApi
  include HTTParty
  require 'uri'
  base_uri 'http://developer.echonest.com/api/v4/artist/search?api_key=WITDBGZPPHKHUCPLK&format=json&name='

  def get_artist_info(artist)
    self.class.get("#{URI.escape(artist.squish)}&bucket=biographies&bucket=images&bucket=genre&bucket=hotttnesss&results=1")
  end
end