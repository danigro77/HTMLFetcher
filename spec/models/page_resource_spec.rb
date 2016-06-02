require 'rails_helper'

RSpec.describe PageResource, type: :model do
  let(:page_resource) { FactoryGirl.create(:page_resource) }

  # Validations
  # ===========
  describe "Validations" do
    it "has a valid factory" do
      expect( FactoryGirl.create(:page_resource) ).to be_valid
      expect( FactoryGirl.create(:recent_resource) ).to be_valid
      expect( FactoryGirl.create(:old_resource) ).to be_valid
    end
    it "is invalid without an URL" do
      expect( FactoryGirl.build(:page_resource, url: nil)).not_to be_valid
    end
    it "is invalid when a non-URL is passed in" do
      ['this-is-not-an-url', '', 'htt://test.com', 'http:/test.com'].each do |url|
        expect( FactoryGirl.build(:page_resource, url: url)).not_to be_valid
      end
    end
  end

  # Relations
  # =========
  describe 'Relations' do
    it { should have_many(:jobs) }
  end

  # Methods
  # =======
  describe 'Class Methods' do

  end
  describe 'Instance Methods' do

  end

  # Filter
  # ======
  describe 'Filter' do

  end
end