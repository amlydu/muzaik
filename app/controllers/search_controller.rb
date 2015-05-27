class SearchController < ApplicationController
  def search #put it in its own controller so we aren't searching only one thing
    if params[:search].strip.empty?
      @artists = []
      @albums = []
      return
    end
    @artist_search = Sunspot.search [Artist] do #use Sunspot search on [artists]
      fulltext params[:search] #look through the full text by :searching
    end

    @album_search = Sunspot.search [Album] do
      fulltext params[:search]
    end
    @albums = @album_search.results
    @artists = @artist_search.results
  end

# @sunspot_search = Sunspot.search User, Tag, Product do |query|
#   query.keywords @search_query
#   query.with(:age).greater_than 20
#   query.with(:age).less_than 25
#   query.paginate(:page => params[:page], :per_page => 30)
# end

# def searchalbum
#   if params[:q].nil?
#     @albums = []
#   else
#     @albums = Album.search params[:q]
#   end

#end

end
