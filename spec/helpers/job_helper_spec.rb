require 'rails_helper'

describe JobHelper do

  describe '.handle_job_request' do
    let(:page_resource_done) { FactoryGirl.create(:recent_resource) }
    let(:page_resource_old) { FactoryGirl.create(:old_resource) }
    let(:page_resource_failed) { FactoryGirl.create(:new_failed_resource) }

    let(:url_uptodate) { page_resource_done.url }
    let(:url_outdated) { page_resource_old.url }
    let(:url_failed) { page_resource_failed.url }
    let(:url_creating) { Faker::Internet.url }

    it 'returns an Array' do
      expect(helper.handle_job_request(url_uptodate)).to be_a Array
      expect(helper.handle_job_request(url_outdated)).to be_a Array
      expect(helper.handle_job_request(url_failed)).to be_a Array
      expect(helper.handle_job_request(url_creating)).to be_a Array
    end

    context 'when the URL is new' do
      let(:url) { url_creating }

      it 'there should be no PageResource with this URL be found' do
        expect(PageResource.find_by(url: url)).to be_nil
      end
      it 'should create a new PageResource with the URL and a job with the status creating' do
        expect{helper.handle_job_request(url)}.to change{PageResource.all.count}.by(1)
        @page_resource = PageResource.last
        expect(@page_resource.url).to eq url
        expect(@page_resource.latest_job.status).to eq 'creating'
      end
    end

    context 'when URL was recently fetched' do
      let(:url) { url_uptodate }
      let!(:page_resource) { page_resource_done }
      let(:page_resource_update) { page_resource_done.updated_at }

      it 'there should be a PageResource with this URL be found' do
        expect(PageResource.find_by(url: url)).to eq page_resource
      end
      it 'nothing should change for the PageResource' do
        expect{helper.handle_job_request(url)}.to change{PageResource.all.count}.by(0)
        page_resource.reload
        expect(page_resource.updated_at).to eq page_resource_update
      end
      it 'the Jobs status should be set to done' do
        expect(page_resource.latest_job.status).to eq 'done'
      end
    end
    context 'when URL was fetched before, but is outdated' do
      let(:url) { url_outdated }
      let!(:page_resource) { page_resource_old }
      let(:page_resource_update) { page_resource_done.updated_at }

      it 'there should be a PageResource with this URL be found' do
        expect(PageResource.find_by(url: url)).to eq page_resource
      end
      it 'the existing PageResource should be updated' do
        expect{helper.handle_job_request(url)}.to change{PageResource.all.count}.by(0)
        page_resource.reload
        expect(page_resource.updated_at).to_not eq page_resource_update
      end
      it 'the Jobs status should be set to done' do
        expect(page_resource.latest_job.status).to eq 'done'
      end
    end
    context 'when URL was fetched before, but the request failed (but the target page exists)' do
      let(:url) { url_failed }
      let!(:page_resource) { page_resource_failed }
      let(:page_resource_update) { page_resource_done.updated_at }
      let(:job) { page_resource.latest_job }

      it 'there should be a PageResource with this URL be found' do
        expect(PageResource.find_by(url: url)).to eq page_resource
      end
      it 'the existing PageResource should be updated' do
        expect{helper.handle_job_request(url)}.to change{PageResource.all.count}.by(0)
        page_resource.reload
        expect(page_resource.updated_at).to_not eq page_resource_update
      end
    end
  end

end