require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:job) { FactoryGirl.create(:job) }

  # Validations
  # ===========
  describe "Validations" do
    it "has a valid factory" do
      expect( FactoryGirl.create(:job) ).to be_valid
      expect( FactoryGirl.create(:updating_job) ).to be_valid
      expect( FactoryGirl.create(:creating_job) ).to be_valid
      expect( FactoryGirl.create(:successful_job) ).to be_valid
      expect( FactoryGirl.create(:failed_job) ).to be_valid
    end
  end

  # Relations
  # =========
  describe 'Relations' do
    it { should belong_to(:page_resource) }
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