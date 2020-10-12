class Post < ApplicationRecord
  DEFAULT_TOP_COUNT = 5

  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :avg_rating, :inclusion => 0..5
  validates :title, presence: true
  validates :content, presence: true
  validates :user, presence: true

  # Calculate #avg_rating
  # return [Post]
  def calc_average!
    update!(avg_rating: ratings.average(:rating))
  end

  def self.top(n = DEFAULT_TOP_COUNT)
    order(avg_rating: :desc, id: :desc).limit(n)
  end

end
