class WikiApi
	include HTTParty
	base_uri 'http://en.wikipedia.org/wiki'

	def get_artist_info(artist, type = nil)
		if type == nil
			self.class.get("/#{artist.squish.tr(" ","_")}")
		else
			self.class.get("/#{artist.squish.tr(" ","_")}_(#{type})")
		end
	end
end