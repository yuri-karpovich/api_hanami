# frozen_string_literal: true
require_relative '../spec_helper'

RSpec.describe User, :type => :model do
  subject { described_class.new(login: Faker::Name.unique.last_name) }
  let(:post) { subject.posts.new(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                                 content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' ')) }

  describe 'validations' do
    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login) }
  end

  describe 'associations' do
    it { should have_many(:posts).without_validating_presence }
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a login' do
    subject.login = nil
    expect(subject).to_not be_valid
  end

  it 'can show ip of user posts' do
    expect(subject.ips).to eq([])
    ips = [Faker::Internet.ip_v4_address.to_s, Faker::Internet.ip_v4_address.to_s]
    subject.posts.new(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                      content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                      ip:      ips.first)
    subject.posts.new(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                      content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                      ip:      ips.last)
    subject.save
    expect(subject.ips.sort).to match_array(ips.sort)
  end

end
