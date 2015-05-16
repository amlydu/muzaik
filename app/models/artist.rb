class Artist < ActiveRecord::Base
  has_many :albums
  #songs we're seeing if this is inherited through albums

  TYPES = [nil, "musician", "group", "band"]

  def save_artist_biography
  	TYPES.each do |type|
  		response = wiki_api.get_artist_info(self.name, type)
  		dom = Nokogiri::HTML(response.body)
  		if response.code == 200
  			summary = dom.css("#mw-content-text p").first
        self.biography = summary.content
        self.save
      end
  	end
  end

  private
    def wiki_api
      @api ||= WikiApi.new
    end
end
