RSpec.describe User do
  include Rack::Test::Methods
  let(:user) { described_class.create!(login: Faker::Name.unique.last_name) }
  let(:another_user) { described_class.create!(login: Faker::Name.unique.last_name) }

  let(:user_ip_endpoint) { '/api/v1/users/ip' }

  # Create posts wih IP addresses
  # @return [Array<Post>]
  # @param user [User] User
  # @param count [Fixnum] count of posts
  def seed_posts_with_ip(user, count)
    (1..count).map do
      Post.create!(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                   content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                   ip:      Faker::Internet.ip_v4_address.to_s,
                   user:    user)
    end
  end


  # Get user IP list via JSON API
  # @return [Rack::MockResponse]
  # @param logins [String] users logins divided by space
  def get_user_ip_list(logins)
    mock_request = Rack::MockRequest.new(APP)
    mock_request.get(user_ip_endpoint, { 'router.params' => { logins: logins }, format: :json })
  end

  it 'IP addresses list can be shown' do
    response = get_user_ip_list [user.login, another_user.login].join(' ')
    expect(response.status).to eql(200)

    user_ips_count = 4
    seed_posts_with_ip(user, user_ips_count)
    response    = get_user_ip_list [user.login, another_user.login].join(' ')
    parsed_body = JSON.parse(response.body)['data']
    expect(response.status).to eql(200)
    expect(parsed_body.find { |h| h['id'] == "#{user.id}" }['attributes']['ips'].count).to eq(user_ips_count)

    another_user_ips_count = 7
    seed_posts_with_ip(another_user, another_user_ips_count)
    response    = get_user_ip_list [user.login, another_user.login].join(' ')
    parsed_body = JSON.parse(response.body)['data']
    expect(response.status).to eql(200)
    expect(parsed_body.find { |h| h['id'] == "#{another_user.id}" }['attributes']['ips'].count).to eq(another_user_ips_count)
  end

end
