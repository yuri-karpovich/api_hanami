class Rating < ApplicationRecord
  ALLOWED_RANGE = 1..5
  belongs_to :post

  validates :rating, presence: true, inclusion: {:in => ALLOWED_RANGE, message: 'allowed rating range is from 1 tp 5'}
  validates :post, presence: true

  after_create :update_post_avg

  # Update post #avg_rating value
  # return [Post]
  def update_post_avg
    post.calc_average!
  end

end