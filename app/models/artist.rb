class Artist < ActiveRecord::Base
  require 'uri'
  # Before validation prevents the same artist being entered twice with different capitalization.
  before_validation :format_name
  after_create  :get_musicbrainz_albums_and_ids,
                :get_album_tracklist,
                :get_album_cover
  validates :name, presence: true, uniqueness: true
  validates :genre, length: { minimum: 1 }
  has_many :albums
  accepts_nested_attributes_for :albums
  ratyrate_rateable "overall"

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
  def update_rake_task
    puts "Updating database with any new artist, album, and song information..."

    #Sort artists in descending order by created_at date and storing this into a variable
    artists = Artist.all.sort_by &:created_at
    #iterate through all instances of artists
    artists.each do |artist|
      #api_call = [information returned by API for artist]
      response = echno_nest_api.get_artist_info(self.name)
      body = JSON.parse response.body
      # The API returns obscure results. The following line will block invalid characters and results that don't contain related info.
      if body['response']['status']['message'] == "Success" && body['response']['artists'] != [] && body['response']['artists'][0]['genres'] != []

        #The biography bucket returns mostly truncated results. The following code will return only full results.
        bios = body['response']['artists'][0]['biographies']
        full_bios = []
        bios.each do |bio|
          if !(bio.include? "truncated") && bio['site'] == "wikipedia"
            full_bios.push(bio)
          end
        end
        bio = full_bios[0]['text'] + "Source: " + full_bios[0]['url']
        hot = body['response']['artists'][0]['hotttnesss']
      end

      if bio != artist.biography
        artist.biography = bio
        artist.save
      end
      if hot != artist.hotttnesss
        artist.hotttnesss = hot
        artist.save
      end
    end
  end

  def format_name
    self.name = self.name.split.map(&:capitalize).join(' ')
    if self.name.include? " And "
      self.name.sub! " And ", " and "
    end
  end

  TYPES = [nil, "musician", "group", "band"]

  def save_artist_wiki_biography
    wiki_page.css("#mw-content-text p").first
    self.biography = summary.content
    self.save
  end

  def artist_echo_info
    response = echno_nest_api.get_artist_info(self.name)
    body = JSON.parse response.body
    # The API returns obscure results. The following line will block invalid characters and results that don't contain related info.
    if body['response']['status']['message'] == "Success" && body['response']['artists'] != [] && body['response']['artists'][0]['genres'] != []
      #The biography bucket returns mostly truncated results. The following code will return only full results.
      bios = body['response']['artists'][0]['biographies']
      full_bios = []
      bios.each do |bio|
        if !(bio.include? "truncated") && bio['site'] == "wikipedia"
          full_bios.push(bio)
        end
      end
      self.biography = full_bios[0]['text'] + "Source: " + full_bios[0]['url']

      self.photo = body['response']['artists'][0]['images'][0]['url']

      self.genre = body['response']['artists'][0]['genres'][0]['name'].capitalize

      self.hotttnesss = body['response']['artists'][0]['hotttnesss']

      picture = body['response']['artists'][0]['images']
      pictures = []
      i = 0

      15.times do
        pictures << picture[i]['url']
        i += 1
      end

      self.picture = pictures
    end
  end

  def related_artists_echo
    response = HTTParty.get(URI.parse("http://developer.echonest.com/api/v4/artist/similar?api_key=WITDBGZPPHKHUCPLK&name=#{URI.encode(self.name.squish)}"))
    body = JSON.parse response.body
    if body['response']['artists'] != nil #body['response']['status']['message'] == "Success" && body['response']['artists'] != [] && body['response']['artists'][0]['genres'] != []
      artists = body['response']['artists']
      related_artists = ""

      artists[0..3].each do |artist|
        related_artists << artist['name'] + ", "
      end
      self.related_artist = related_artists + artists[4]['name']
    end
  end

  def twitter_echo
    response = HTTParty.get(URI.parse("http://developer.echonest.com/api/v4/artist/twitter?api_key=WITDBGZPPHKHUCPLK&name=#{URI.encode(self.name.squish)}&format=json"))
    body = JSON.parse response.body
    self.twitter = body['response']['artist']['twitter']
  end

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
      date = dom.css('date').map {|e| e.content}
      album.release_date = date.first
      album.save
      tracklist.each do |song_name|
        album.songs.create(name: song_name)
      end
    end
  end

  def get_album_cover
    self.albums.find_each do |album|
      response = HTTParty.get("http://coverartarchive.org/release/#{album.external_album_id}")
      if response.code == 200
        dom = JSON.parse Nokogiri::HTML(response.body)
        album.photo = dom['images'][0]['image']
        album.save
      else
        album.photo = nil
        album.save
      end
    end
  end

  def destroy_songs
    self.albums.each do |album|
      album.songs.destroy_all
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

