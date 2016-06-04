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
      expect( FactoryGirl.create(:old_updating_resource) ).to be_valid
      expect( FactoryGirl.create(:new_creating_resource) ).to be_valid
      expect( FactoryGirl.create(:new_failed_resource) ).to be_valid
    end
    it "is invalid without an URL" do
      expect( FactoryGirl.build(:page_resource, url: nil)).not_to be_valid
    end
    it "is invalid when a non-URL is passed in" do
      ['this-is-not-an-url', '', 'htt://test.com', 'http:/test.com'].each do |url|
        expect( FactoryGirl.build(:page_resource, url: url)).not_to be_valid
      end
    end
    it "is invalid when a URL is already taken" do
      expect( FactoryGirl.build(:page_resource, url: page_resource.url)).not_to be_valid
    end
  end

  # Relations
  # =========
  describe 'Relations' do
    it { should have_many(:jobs) }
  end

  # Methods
  # =======
  describe 'Scopes and Class Methods' do
    describe "Scope #sort_by_popularity" do
      let(:lowest_popularity) { 2 }
      let(:highest_popularity) { 8 }
      let(:mixed_numbers) { (lowest_popularity..highest_popularity).to_a.shuffle }

      before do
        mixed_numbers.each do |popularity|
          FactoryGirl.create(:page_resource, popularity: popularity)
        end
      end

      it 'returns all page resources sorted by popularity' do
        expect(PageResource.all.count).to eq mixed_numbers.count
        expect(PageResource.sort_by_popularity.first.popularity).to eq highest_popularity
        expect(PageResource.sort_by_popularity.last.popularity).to eq lowest_popularity
      end
    end
  end

  describe 'Instance Methods' do
    describe '.latest_job' do
      let(:num_of_jobs) { 3 }
      let(:page_resource) { FactoryGirl.create(:recent_resource, jobs_count: num_of_jobs)}
      let(:expected_job) { page_resource.jobs.sample }
      before do
        expected_job.update(updated_at: DateTime.current)
        expected_job.reload
      end

      it 'returns the most recent updated job' do
        expect(page_resource.jobs.count).to eq num_of_jobs
        expect(page_resource.latest_job).to eq expected_job
      end
    end

    describe '.last_creating_job' do
      let(:num_of_jobs) { 3 }
      let(:page_resource) { FactoryGirl.create(:new_creating_resource, jobs_count: num_of_jobs)}
      let(:expected_job) { page_resource.jobs.sample }
      let(:not_expected_job) { (page_resource.jobs - [expected_job]).sample }
      before do
        expected_job.update(updated_at: DateTime.current)
        not_expected_job.update(status: 'done')
        expected_job.reload
        not_expected_job.reload
      end

      it 'returns the most recent updated job with the status creating' do
        expect(page_resource.last_creating_job).to eq expected_job
        expect(page_resource.last_creating_job).to_not eq not_expected_job
      end
    end

    describe '.update_popularity' do
      let(:popularity) { (1..10).to_a.sample }
      let!(:page_resource) { FactoryGirl.create(:new_creating_resource, popularity: popularity) }

      it 'changes the popularity by 1' do
        expect{page_resource.update_popularity}.to change{page_resource.popularity}.by(1)
        expect(page_resource.update_popularity).to be true
      end
    end

    describe '.needs_updating?' do
      let(:page_resource_outdated) { FactoryGirl.create(:old_resource) }
      let(:page_resource_new) { FactoryGirl.create(:recent_resource) }
      let(:page_resource_without_done) { FactoryGirl.create(:old_updating_resource) }

      it 'returns true when the object has done jobs and is outdated' do
        expect(page_resource_outdated.needs_updating?).to be true
      end
      it 'returns false when the object has done jobs and but is recent' do
        expect(page_resource_new.needs_updating?).to be false
      end
      it 'returns false when the object has no done jobs and but is outdated' do
        expect(page_resource_without_done.needs_updating?).to be false
      end
    end

    describe '.is_outdated?' do
      let(:page_resource_outdated) { FactoryGirl.create(:old_resource) }
      let(:page_resource_new) { FactoryGirl.create(:recent_resource) }

      it 'returns true when the object is older than from yesterday' do
        expect(page_resource_outdated.is_outdated?).to be true
      end
      it 'returns false when the object is recent' do
        expect(page_resource_new.is_outdated?).to be false
      end
    end

    describe '.has_<STATUS>_jobs?' do
      let(:page_resource_done) { FactoryGirl.create(:recent_resource) }
      let(:page_resource_creating) { FactoryGirl.create(:new_creating_resource) }
      let(:page_resource_updating) { FactoryGirl.create(:old_updating_resource) }
      let(:page_resource_failed) { FactoryGirl.create(:new_failed_resource) }

      describe '.has_creating_jobs?' do
        it 'returns true if it has creating jobs' do
          expect(page_resource_creating.has_creating_jobs?).to be true
        end
        it 'returns false if it has no creating jobs' do
          expect(page_resource_done.has_creating_jobs?).to be false
          expect(page_resource_updating.has_creating_jobs?).to be false
          expect(page_resource_failed.has_creating_jobs?).to be false
        end
      end
      describe '.has_updating_jobs?' do
        it 'returns true if it has updating jobs' do
          expect(page_resource_updating.has_updating_jobs?).to be true
        end
        it 'returns false if it has no updating jobs' do
          expect(page_resource_done.has_updating_jobs?).to be false
          expect(page_resource_creating.has_updating_jobs?).to be false
          expect(page_resource_failed.has_updating_jobs?).to be false
        end
      end
      describe '.has_done_jobs?' do
        it 'returns true if it has done jobs' do
          expect(page_resource_done.has_done_jobs?).to be true
        end
        it 'returns false if it has no done jobs' do
          expect(page_resource_updating.has_done_jobs?).to be false
          expect(page_resource_creating.has_done_jobs?).to be false
          expect(page_resource_failed.has_done_jobs?).to be false
        end
      end
      describe '.has_failed_jobs?' do
        it 'returns true if it has failed jobs' do
          expect(page_resource_failed.has_failed_jobs?).to be true
        end
        it 'returns false if it has no failed jobs' do
          expect(page_resource_updating.has_failed_jobs?).to be false
          expect(page_resource_creating.has_failed_jobs?).to be false
          expect(page_resource_done.has_failed_jobs?).to be false
        end
      end
    end
  end

  # Filter
  # ======
  describe 'Filter' do

  end
end