desc "This task is called by the Heroku scheduler add-on to update the Muzaik database"
task :update_database => :environment do
  puts "Updating database with any new artist, album, and song information..."

  #Sort artists in descending order by created_at date and storing this into a variable
  artists = Artist.all.sort_by &:created_at
  #iterate through all instances of artists
  artists.each do |artist|
    #api_call = [information returned by API for artist]
    response = HTTParty.get("http://developer.echonest.com/api/v4/artist/search?api_key=WITDBGZPPHKHUCPLK&format=json&name=#{URI.encode(artist.name.squish)}&bucket=biographies&bucket=images&bucket=genre&bucket=hotttnesss&results=1")
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


    #Array of albums from API
    album_response = HTTParty.get("http://musicbrainz.org/ws/2/release-group/?query=artist:%22#{URI.encode(artist.name.squish)}%22%20AND%20primarytype:%22album%22")
    dom = Nokogiri::XML(album_response.body)

    #getting all album names
    album = dom.css('release-list release title')
    #getting all album ids
    album_id = dom.css('release-list release')

    #initializing arrays
    existing_records = []
    records = []
    ids = []
    all_the_records = []

    artist.albums.each do |album|
      existing_records << album.name
    end

    #populating above arrays album names and associated musicbrainz ids
    until album_id.length == 0
      ids << album_id.pop.attributes['id'].value
    end
    until album.length == 0
      records << album.pop.children.text
    end

    existing_records << records

    unless existing_records.uniq.length > 0
      artist.albums.destroy_all
      combined_hash = {}

      #creating one hash mapping record names to ids
      ids.each_with_index do |val, key|
        combined_hash[records[key]] = val
      end

      #saving values in albums model
      combined_hash.each do |key, val|
        artist.albums.create(name: key, external_album_id: val)
      end

      #Grabbing other Album information
      artist.albums.find_each do |album|
        response = HTTParty.get("http://musicbrainz.org/ws/2/release/#{album.external_album_id}?inc=recordings")
        dom2 = Nokogiri::XML(response.body)

      #array of songs
        tracklist = dom2.css('track title').map {|e| e.content}
        date = dom2.css('date').map {|e| e.content}
        album.release_date = date.first
        album.save
        tracklist.each do |song_name|
          album.songs.create(name: song_name)
        end
      end
      artist.albums.find_each do |album|
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
  end

  puts "Completed update."
end
