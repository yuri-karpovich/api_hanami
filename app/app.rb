class App < Hanami::API
  scope 'api' do
    scope 'v1' do
      scope 'users' do
        get 'ip' do
          logins = params[:logins].to_s.split.map(&:strip)
          halt(422, "logins must be specified") if logins.empty?
          users = User.where(login: logins)
          json(UserSerializer.new(users, { params: { ips: true } }).serializable_hash)
        end

      end

      scope 'posts' do

        post '/' do
          user = User.find_or_create_by!(login: params[:login])
          post = user.posts.create!(title: params[:title], content: params[:content], ip: params[:ip])

          [200, json(PostSerializer.new(post, { params: { relations: true } }).serializable_hash)]
        rescue ActiveRecord::RecordInvalid => e
          [422, json(error: e.message)]
        end


        get '/' do
          count = params[:count] || Post::DEFAULT_TOP_COUNT
          posts = Post.top count

          [200, json(PostSerializer.new(posts).serializable_hash)]
        end


        put ':id' do
          post = Post.find(params[:id])
          post.ratings.create!(rating: params[:rating])

          [200, json(PostSerializer.new(post).serializable_hash)]
        rescue ActiveRecord::RecordInvalid => e
          [422, json(error: e.message)]
        end

      end
    end
  end
end
