class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :songs
  has_many :ratings
  has_many :users, through: :ratings
  accepts_nested_attributes_for :songs

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

end
