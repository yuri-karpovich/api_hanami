# frozen_string_literal: true
require_relative '../spec_helper'

RSpec.describe Post, :type => :model do
  subject { described_class.new(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                                content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '),
                                ip:      Faker::Internet.ip_v4_address.to_s,
                                user:    User.new(login: Faker::Name.unique.last_name)) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_inclusion_of(:avg_rating).in_range(0..5) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should have_many(:ratings) }
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is valid without ip attributes' do
    subject.ip = nil
    expect(subject).to be_valid
  end

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a content' do
    subject.content = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a user' do
    subject.user = nil
    expect(subject).to_not be_valid
  end

  it 'can calculate average posts rating' do
    expect(subject.avg_rating).to equal(0)

    subject.ratings.new(rating: 1)
    subject.save
    expect(subject.avg_rating).to equal(1)

    subject.ratings.new(rating: 5)
    subject.save
    expect(subject.avg_rating).to equal(3)
  end

end
