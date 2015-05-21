class Artist < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :albums
  accepts_nested_attributes_for :albums
  #songs we're seeing if this is inherited through albums

################ Search tutorial #############################
  searchable do
    text :name

    # boolean :featured
    # integer :blog_id
    # integer :author_id
    # integer :category_ids, :multiple => true
    # double  :average_rating
    # time    :published_at
    # time    :expired_at

    # string  :sort_title do
    #   title.downcase.gsub(/^(an?|the)/, '')
    # end
  end

######################Search Tutorial ####################


  TYPES = [nil, "musician", "group", "band"]

  def save_artist_wiki_biography
    wiki_page.css("#mw-content-text p").first
    self.biography = summary.content
    self.save
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
  # def save_musicbrainz_discography
  #   response = musicbrainz_api.get_artist_info(self.name)
  #   dom = Nokogiri::XML(response.body)
  #   albums = dom.css('release title').map { |e| e.content }
  #   self.album.external_album_id = dom.css('release-list release').first.attributes['id'].value
  #   albums.uniq.each do |album|
  #     self.albums.create(name: album)
  #   end
  # end


  def get_musicbrainz_albums_and_ids
    response = musicbrainz_api.get_artist_info(self.name)
    dom = Nokogiri::XML(response.body)

    #getting all album names
    album = dom.css('release-list release title')

    #getting all album ids
    album_id = dom.css('release-list release')

    #initializing arrays
    records = []
    ids = []

    #populating above arrays album names and associated musicbrainz ids
    until album_id.length == 0
      ids << album_id.pop.attributes['id'].value
    end
    until album.length == 0
      records << album.pop.children.text
    end

    combined_hash = {}

    #creating one hash mapping record names to ids
    ids.each_with_index do |val, key|
      combined_hash[records[key]] = val
    end

    #saving values in albums model
    combined_hash.each do |key, val|
      self.albums.create(name: key, external_album_id: val)
    end
  end

 # assign external_album_ids to albums
 #  iterate through albums, running Nokogiri to get tracklist for each album and save it. \
  def get_album_tracklist
    self.albums.find_each do |album|
      response = HTTParty.get("http://musicbrainz.org/ws/2/release/#{album.external_album_id}?inc=recordings")
      dom = Nokogiri::XML(response.body)

      #array of songs
      tracklist = dom.css('track title').map {|e| e.content}
      tracklist.each do |song_name|
        album.songs.create(name: song_name)
        #self.albums.find_by(external_album_id: "album.external_album_id").songs.create(name: song_name)
      end
    end
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

# Artist.import # for auto sync model with elastic search

