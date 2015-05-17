class Artist < ActiveRecord::Base
  has_many :albums
  #songs we're seeing if this is inherited through albums

  TYPES = [nil, "musician", "group", "band"]

  def save_artist_wiki_biography
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

  def save_artist_echo_info
    response = echno_nest_api.get_artist_info(self.name)
    body = JSON.parse response.body

    #The biography bucket returns mostly truncated results. The following code will return only full results.
    bios = body['response']['artists'][0]['biographies']
    full_bios = []
    bios.each do |bio|
      if !(bio.include? "truncated")
        full_bios.push(bio)
      end
    end
    self.biography = full_bios[0]['text'] + "Source: " + full_bios[0]['url']

    self.photo = body['response']['artists'][0]['images'][1]['url']

    genre = body['response']['artists'][0]['genres'][1]['name']
    self.genre = genre.capitalize

    self.save
  end

  private
    def wiki_api
      @api ||= WikiApi.new
    end

    def echno_nest_api
      @api ||= EchoNestApi.new
    end
end