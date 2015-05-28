desc "This task is called by the Heroku scheduler add-on to update the Muzaik database"
task :update_database => :environment do
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

  puts "Completed update."
end
