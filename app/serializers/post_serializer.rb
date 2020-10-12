class PostSerializer
  include FastJsonapi::ObjectSerializer

  # Uncomment if you want to return relations as well
  # belongs_to :user, if: Proc.new { |_record, params| params && params[:relations] == true }

  attributes :id, :title, :content, :ip, :avg_rating, :user_id
end