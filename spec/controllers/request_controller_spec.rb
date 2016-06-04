require 'rails_helper'

RSpec.describe RequestController, :type => :controller do
  let(:url) { Faker::Internet.url }

  describe 'GET #job' do
    it 'responds successfully' do
      url = "http://pablokohls.herokuapp.com"
      get :job, { url: url }
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'fails without the expected params' do
      get :job, { url: 'not-an-url' }
      expect(response).to_not be_success
      expect(response).to have_http_status(400)
    end

    context 'when new request' do
      let!(:all_pages) { PageResource.all.count }
      let!(:all_jobs) { Job.all.count }

      before do
        get :job, { url: url }
      end

      it 'creates a PageResource' do
        expect(PageResource.all.count).to eq all_pages+1
      end

      it 'creates a Job' do
        expect(Job.last.status).to eq "creating"
        expect(Job.all.count).to eq all_jobs+1
      end

      it 'returns a job_id' do
        new_job = Job.last
        expect(response.body).to eq({job_id: new_job.id, job_status: new_job.status, page_id: new_job.page_resource.id}.to_json)
      end
    end

    context 'when existing page data is outdated' do
      let!(:reuse_url) { url }
      let!(:old_requested_page) { FactoryGirl.create(:old_resource, url:reuse_url)}
      let!(:all_pages) { PageResource.all.count }
      let!(:all_jobs) { Job.all.count }
      let!(:old_popularity) { old_requested_page.popularity }
      let!(:old_updated_at) { old_requested_page.updated_at }

      before do
        get :job, { url: reuse_url }
      end

      it 'reuses and updates a PageResource' do
        expect(PageResource.all.count).to_not eq all_pages+1
        old_requested_page.reload
        expect(old_requested_page.popularity).to eq old_popularity+1
      end

      it 'fetches new data for this PageResource' do
        old_requested_page.reload
        expect(old_requested_page.updated_at).to_not eq old_updated_at
      end

      it 'creates a Job' do
        expect(Job.last.page_resource).to eq old_requested_page
        expect(Job.last.status).to eq "updating"
        expect(Job.all.count).to eq all_jobs+1
      end

      it 'returns a job_id' do
        new_job = Job.last
        expect(response.body).to eq({job_id: new_job.id, job_status: new_job.status, page_id: new_job.page_resource.id}.to_json)
      end
    end

    context 'when existing page data is recent' do
      let!(:reuse_url) { url }
      let!(:old_requested_page) { FactoryGirl.create(:recent_resource, url:reuse_url)}
      let!(:all_pages) { PageResource.all.count }
      let!(:all_jobs) { Job.all.count }
      let!(:old_popularity) { old_requested_page.popularity }
      let!(:old_html) { old_requested_page.html }

      before do
        get :job, { url: reuse_url }
      end

      it 'reuses and updates a PageResource' do
        expect(PageResource.all.count).to_not eq all_pages+1
        old_requested_page.reload
        expect(old_requested_page.popularity).to eq old_popularity+1
      end

      it 'reuses the existing html data of this PageResource' do
        old_requested_page.reload
        expect(old_requested_page.html).to eq old_html
      end

      it 'creates a Job' do
        expect(Job.last.page_resource).to eq old_requested_page
        expect(Job.last.status).to eq "done"
        expect(Job.all.count).to eq all_jobs+1
      end

      it 'returns a job_id' do
        new_job = Job.last
        {job_id: new_job.id, job_status: new_job.status, page_id: new_job.page_resource.id}.each do |key, value|
          expect(response.body).to match key.to_s
          expect(response.body).to match value.to_s
        end
      end
    end

  end

  describe 'GET #status' do
    let(:job) { FactoryGirl.create(:job) }

    it 'responds successfully' do
      get :status, { job_id: job.id }
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'fails without the expected params' do
      get :status, { job_id: 'bla' }
      expect(response).to_not be_success
      expect(response).to have_http_status(404)
    end

    context 'when job is unfinished' do
      context 'and URL was unknown' do
        let(:page_resource) { FactoryGirl.create(:new_creating_resource, url:url)}
        let!(:request_job) { page_resource.jobs.last }

        before do
          get :status, { job_id: request_job.id }
        end

        it 'returns a status update' do
          expect(response.body).to eq({status: 'creating', job_id: "#{request_job.id}", page_id: page_resource.id, message: I18n.t("status_messages.#{request_job.status}")}.to_json)
        end
      end
      context 'and URL was known but outdated' do
        let(:page_resource) { FactoryGirl.create(:old_updating_resource, url:url)}
        let!(:request_job) { page_resource.jobs.last }

        before do
          get :status, { job_id: request_job.id }
        end

        it 'returns a status update' do
          expect(response.body).to eq({status: 'updating', job_id: "#{request_job.id}", page_id: page_resource.id, message: I18n.t("status_messages.#{request_job.status}")}.to_json)
        end
      end
    end

    context 'when job is finished' do
      let(:page_resource) { FactoryGirl.create(:recent_resource, url:url)}
      let!(:request_job) { page_resource.jobs.last }

      before do
        get :status, { job_id: request_job.id }
      end

      it 'returns a status update' do
        expect(response.body).to eq({status: 'done', job_id: "#{request_job.id}", page_id: page_resource.id, html: page_resource.html}.to_json)
      end
    end

    context 'when job has failed' do
      let(:page_resource) { FactoryGirl.create(:new_failed_resource, url:url)}
      let!(:request_job) { page_resource.jobs.last }

      before do
        get :status, { job_id: request_job.id }
      end

      it 'returns a status update' do
        expect(response.body).to eq({status: 'failed', job_id: "#{request_job.id}", page_id: page_resource.id, message: I18n.t("status_messages.#{request_job.status}")}.to_json)
      end
    end
  end

end