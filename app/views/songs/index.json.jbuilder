json.array!(@songs) do |song|
  json.extract! song, :id, :name
  json.url song_url(song, format: :json)
end
