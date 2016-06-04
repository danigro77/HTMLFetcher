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
  describe 'Scopes and Class Methods' do
    describe "Scope #all_creating" do
      let(:random_number) { (2..8).to_a.sample }

      before do
        random_number.times do
          FactoryGirl.create(:creating_job)
          FactoryGirl.create(:successful_job)
        end
      end

      it 'returns all jobs with status creating' do
        expect(Job.all.count).to eq random_number*2
        expect(Job.all_creating.count).to eq random_number
        expect(Job.all_creating.first.status).to eq 'creating'
      end
    end

    describe "Scope #all_not_failed" do
      let(:random_number) { (2..8).to_a.sample }

      before do
        random_number.times do
          FactoryGirl.create(:creating_job)
          FactoryGirl.create(:failed_job)
        end
      end

      it 'returns all jobs except the ones with status failed' do
        expect(Job.all.count).to eq random_number*2
        expect(Job.all_not_failed.count).to eq random_number
        expect(Job.all_not_failed.first.status).to_not eq 'failed'
      end
    end
  end
  describe 'Instance Methods' do

  end

  # Filter
  # ======
  describe 'Filter' do

  end
end