RSpec.describe Post do
  include Rack::Test::Methods
  subject { described_class.create(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                                   content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                                   ip:      Faker::Internet.ip_v4_address.to_s,
                                   user:    User.new(login: Faker::Name.unique.last_name)) }
  let(:new_post_params) { { title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                            content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                            ip:      Faker::Internet.ip_v4_address.to_s,
                            login:   User.new(login: Faker::Name.unique.last_name) } }
  let(:new_post_endpoint) { 'api/v1/posts' }
  let(:rate_post_endpoint) { "api/v1/posts/#{subject.id}" }
  let(:top_posts_endpoint) { '/api/v1/posts' }

  # Create post via JSON API
  # @return [Rack::MockResponse]
  # @param params [Hash] params
  def create_post(params)
    mock_request = Rack::MockRequest.new(APP)
    mock_request.post(new_post_endpoint, { 'router.params' => params, format: :json })
  end

  # Rate post via JSON API
  # @return [Rack::MockResponse]
  # @param rating [Fixnum] value drom 1 to 5
  def rate_post(rating)
    mock_request = Rack::MockRequest.new(APP)
    mock_request.put(rate_post_endpoint, { 'router.params' => { rating: rating }, format: :json })
  end

  # Get top rated posts via JSON API
  # @return [Rack::MockResponse]
  # @param count [Fixnum] count of posts
  def top_posts(count = nil)
    mock_request = Rack::MockRequest.new(APP)
    return mock_request.get(top_posts_endpoint) unless count

    mock_request.get(top_posts_endpoint, { 'router.params' => { count: count }, format: :json })
  end

  # Create posts wih ratings
  # @return [Array<Post>]
  # @param count [Fixnum] count of posts
  def seed_posts(count)
    (1..count).map do
      post = Post.create!(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                          content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                          user:    User.create!(login: Faker::Name.unique.last_name))
      post.ratings.create!(rating: rand(1..5))
      post
    end
  end

  it 'is create with valid params' do
    response = create_post new_post_params
    expect(response.status).to eql(200)

    parsed_body = JSON.parse(response.body)
    element_id  = parsed_body['data']['id']
    element     = described_class.find(element_id)
    expect(parsed_body['data']['attributes']['title']).to eq(element.title)
    expect(parsed_body['data']['attributes']['content']).to eq(element.content)
    expect(parsed_body['data']['attributes']['ip']).to eq(element.ip)
    expect(parsed_body['data']['attributes']['user_id']).to eq(element.user.id)
  end

  it 'is create with missed ip param' do
    test_params = new_post_params.dup
    test_params.delete(:ip)
    response = create_post test_params
    expect(response.status).to eql(200)

    parsed_body = JSON.parse(response.body)
    element_id  = parsed_body['data']['id']
    element     = described_class.find(element_id)
    expect(parsed_body['data']['attributes']['title']).to eq(element.title)
    expect(parsed_body['data']['attributes']['content']).to eq(element.content)
    expect(parsed_body['data']['attributes']['ip']).to be_nil
    expect(parsed_body['data']['attributes']['user_id']).to eq(element.user.id)
  end

  it 'is not create with missed title param' do
    test_params = new_post_params.dup
    test_params.delete(:title)
    response = create_post test_params
    expect(response.status).to eql(422)

    parsed_body = JSON.parse(response.body)
    expect(parsed_body['error']).to eq("Validation failed: Title can't be blank")
  end

  it 'is not create with missed content param' do
    test_params = new_post_params.dup
    test_params.delete(:content)
    response = create_post test_params
    expect(response.status).to eql(422)

    parsed_body = JSON.parse(response.body)
    expect(parsed_body['error']).to eq("Validation failed: Content can't be blank")
  end

  it 'is not create with missed login param' do
    test_params = new_post_params.dup
    test_params.delete(:login)
    response = create_post test_params
    expect(response.status).to eql(422)

    parsed_body = JSON.parse(response.body)
    expect(parsed_body['error']).to eq("Validation failed: Login can't be blank")
  end

  it 'rating can be changed' do
    initial_rating = 1
    new_rating     = 5
    response       = rate_post initial_rating
    expect(response.status).to eql(200)

    parsed_body = JSON.parse(response.body)
    expect(parsed_body['data']['id']).to eq("#{subject.id}")
    expect(parsed_body['data']['attributes']['title']).to eq(subject.title)
    expect(parsed_body['data']['attributes']['content']).to eq(subject.content)
    expect(parsed_body['data']['attributes']['ip']).to eq(subject.ip)
    expect(parsed_body['data']['attributes']['user_id']).to eq(subject.user.id)
    expect(parsed_body['data']['attributes']['avg_rating']).to eq(1)
    expect(subject.ratings.count).to eq(1)

    response = rate_post new_rating
    expect(response.status).to eql(200)

    parsed_body = JSON.parse(response.body)
    expect(parsed_body['data']['id']).to eq("#{subject.id}")
    expect(parsed_body['data']['attributes']['title']).to eq(subject.title)
    expect(parsed_body['data']['attributes']['content']).to eq(subject.content)
    expect(parsed_body['data']['attributes']['ip']).to eq(subject.ip)
    expect(parsed_body['data']['attributes']['user_id']).to eq(subject.user.id)
    expect(parsed_body['data']['attributes']['avg_rating']).to eq(3)
    expect(subject.ratings.count).to eq(2)
  end

  it 'invalid rating cannot be set' do
    invalid_rating = 6
    expect(subject.ratings.count).to eq(0)

    response = rate_post invalid_rating
    expect(response.status).to eql(422)
    expect(subject.ratings.count).to eq(0)
    expect(JSON.parse(response.body)['error']).to eq('Validation failed: Rating allowed rating range is from 1 tp 5')
  end

  it 'top rated list can be pulled' do
    response = top_posts
    expect(response.status).to eql(200)
    expect(JSON.parse(response.body)['data']).to eq([])

    seed_posts 30
    response = top_posts
    expect(JSON.parse(response.body)['data'].count).to eq(5)

    expected_value = described_class.top.pluck(:id).map(&:to_s)
    api_result     = JSON.parse(response.body)['data'].map { |h| h['id'] }
    expect(expected_value).to eq(api_result)
  end

  it 'top rated list size can be changed' do
    response = top_posts
    expect(response.status).to eql(200)
    expect(JSON.parse(response.body)['data']).to eq([])

    seed_posts 30
    response = top_posts 15
    expect(JSON.parse(response.body)['data'].count).to eq(15)
  end


end