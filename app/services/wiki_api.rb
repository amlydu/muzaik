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

	# def parsed_artist_info
		
	# end
 #      dom = Nokogiri::HTML(response.body)
 #      if dom.include? "Discography"
 #        biography = dom.css("#mw-content-text p").first
 #        @artist.biography = biography.content
 #      elsif !(dom.include? "Discography") &&  
 #        url += "_(musician)"
 #        response = HTTParty.get(url)
 #        dom = Nokogiri::HTML(response.body)
 #        summary = dom.css("#mw-content-text p").first
 #        @artist.summary = summary.content
 #      elsif !dom.include? "Discography"
 #      	url += "_(group)"

 #        types = [nil, _(musician), _(group), _(band)]
end