class UserSerializer
  include FastJsonapi::ObjectSerializer

  # Uncomment if you want to return relations as well
  # has_many :posts, if: Proc.new { |_record, params| params && params[:relations] == true }

  attributes :id, :login
  attribute :ips, if: Proc.new { |_record, params|
    # The ips will be serialized only if the :ips key of params is true
    params && params[:ips]
  }
  attribute :ips do |user|
    user.ips
  end
end