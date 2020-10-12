# frozen_string_literal: true
require_relative '../spec_helper'

RSpec.describe Rating, :type => :model do
  subject { described_class.new(rating: rand(Rating::ALLOWED_RANGE),
                                post:   Post.new(title:   Faker::Lorem.words(number: rand(2..10)).join(' '),
                                                 content: Faker::Lorem.paragraphs(number: rand(2..8)).join(' '))) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is not valid without a rating' do
    subject.rating = nil
    expect(subject).to_not be_valid
  end

  describe 'validations' do
    it { should validate_presence_of(:rating) }
    it { should validate_inclusion_of(:rating).in_range(Rating::ALLOWED_RANGE).with_message('allowed rating range is from 1 tp 5') }
  end

  describe 'Associations' do
    it { should belong_to(:post) }
  end

end
