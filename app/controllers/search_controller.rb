class SearchController < ApplicationController
def search #part of tutorial
  if params[:q].nil?
    @artist = []
  else
    @artist = Artist.search params[:q]
  end
end

end
