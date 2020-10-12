require 'faker'
require 'parallel'
require 'etc'
require 'faraday'


SERVER            = '127.0.0.1:9292'.freeze
CPUS              = Etc.nprocessors
TOTAL_POSTS_COUNT = 200_000
PARALLEL_REQUESTS = 50


def create_post(login, title, content, ip = nil)
  uri       = URI.parse("http://#{SERVER}/api/v1/posts/new?login=#{login}&title=#{title}&content=#{content}")
  uri.query = +[uri.query, "ip=#{ip}"].compact.join('&') if ip
  resp      = Faraday.post(uri)
  puts resp unless resp.success?
end

def rate_posts(post_id, rating)
  uri  = URI.parse("http://#{SERVER}/api/v1/posts/#{post_id}/rate?rating=#{rating}")
  resp = Faraday.post(uri)
  puts resp unless resp.success?
end


TITLES = Parallel.map(1..(TOTAL_POSTS_COUNT / 10), in_processes: CPUS - 1, progress: "Generating fake data: TITLES") do
  Faker::Lorem.words(number: rand(2..10)).join(' ')
end

CONTENTS = Parallel.map(1..(TOTAL_POSTS_COUNT / 10), in_processes: CPUS - 1, progress: "Generating fake data: CONTENTS") do
  Faker::Lorem.paragraphs(number: rand(2..8)).join(' ')
end

USERS = Parallel.map(1..99, in_threads: CPUS - 1, progress: "Generating fake data: USERS") do
  Faker::Name.unique.last_name.downcase
end
USERS << 'test'

IPS = Parallel.map(1..50, in_threads: CPUS - 1, progress: "Generating fake data: IPS") do
  Faker::Internet.ip_v4_address.to_s
end

Parallel.each(USERS, in_threads: PARALLEL_REQUESTS, progress: "Creating posts from each of #{USERS.count} users") do |login|
  create_post(login, TITLES.sample, CONTENTS.sample, IPS.sample)
end

Parallel.each(IPS, in_threads: PARALLEL_REQUESTS, progress: "Creating posts from each of #{IPS.count} ips") do |ip|
  create_post(USERS.sample, TITLES.sample, CONTENTS.sample, ip)
end

Parallel.each(1..TOTAL_POSTS_COUNT, in_processes: PARALLEL_REQUESTS, progress: "Creating #{TOTAL_POSTS_COUNT} posts") do
  create_post(USERS.sample, TITLES.sample, CONTENTS.sample, IPS.sample)
end

Parallel.each(1..(TOTAL_POSTS_COUNT / 2), in_processes: PARALLEL_REQUESTS, progress: "Rate #{TOTAL_POSTS_COUNT / 2} random posts") do
  rate_posts(rand(1..TOTAL_POSTS_COUNT), rand(1..5))
end

Parallel.each(1..5_000, in_processes: PARALLEL_REQUESTS, progress: "Add 10k rates to the same post from #{PARALLEL_REQUESTS} parallel clients") do
  rate_posts(1, rand(1..5))
end