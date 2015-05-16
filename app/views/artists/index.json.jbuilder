json.array!(@artists) do |artist|
  json.extract! artist, :id, :name, :biography, :photo, :genre
  json.url artist_url(artist, format: :json)
end
