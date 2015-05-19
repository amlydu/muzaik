class Artist < ActiveRecord::Base
  has_many :albums
  accepts_nested_attributes_for :albums
  #songs we're seeing if this is inherited through albums

  TYPES = [nil, "musician", "group", "band"]

  def save_artist_wiki_biography
      wiki_page.css("#mw-content-text p").first
      self.biography = summary.content
      self.save
  end


  def save_artist_wiki_discography
    discography = wiki_page.css("#mw-content-text > div.div-col.columns.column-count.column-count-2 > ul li i a").map {|link| [link.text.strip]}

    artist_discography = discography.uniq.flatten
    artist_discography.each do |album|
      self.albums.create(name: album)
    end
  end

  def save_musicbrainz_discography
    response = musicbrainz_api.get_artist_info(self.name)
    dom = Nokogiri::XML(response.body)
    albums = dom.css('release-group title').map { |e| e.content }
    albums.uniq.each do |album|
      self.albums.create(name: album)
    end
  end

  def artist_echo_info
    response = echno_nest_api.get_artist_info(self.name)
    body = JSON.parse response.body

    #The biography bucket returns mostly truncated results. The following code will return only full results.
    bios = body['response']['artists'][0]['biographies']
    full_bios = []
    bios.each do |bio|
      if !(bio.include? "truncated") && bio['site'] == "wikipedia"
        full_bios.push(bio)
      end
    end
    self.biography = full_bios[0]['text'] + "Source: " + full_bios[0]['url']

    self.photo = body['response']['artists'][0]['images'][1]['url']

    self.genre = body['response']['artists'][0]['genres'][1]['name'].capitalize
  end

  private
    def wiki_api
      WikiApi.new
    end

    def echno_nest_api
      EchoNestApi.new
    end

    def musicbrainz_api
      MusicbrainzApi.new
    end

    def wiki_page
      TYPES.each do |type|
        response = wiki_api.get_artist_info(self.name, type)
      return Nokogiri::HTML(response.body) if response.code == 200
    end
  end
end