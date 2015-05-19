class MusicbrainzApi
  include HTTParty
  
  def get_artist_info(artist)
    self.class.get("http://musicbrainz.org/ws/2/release-group/?query=artist:%22#{artist.squish.tr(" ","%20")}%22%20AND%20primarytype:%22album%22")
  end
end