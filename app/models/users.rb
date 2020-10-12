class User < ApplicationRecord
  has_many :posts
  validates :login, presence: true, uniqueness: true

  # Show IP addresses from users's posts
  # return [Array<String>] IP addresses
  def ips
    posts.where.not(ip: [nil, '']).distinct(:ip).pluck(:ip)
  end
end
