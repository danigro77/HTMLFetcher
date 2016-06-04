require 'rails_helper'

RSpec.describe PageFetchWorker, :type => :worker do
  let!(:page_resource) { FactoryGirl.create(:new_creating_resource)}
  let!(:job) { page_resource.latest_job }

  before(:each) do
    FakeWeb.register_uri(:get, page_resource.url, :body => "Hello World!")
  end

  it 'handles jobs' do
    expect { PageFetchWorker.perform_async(job.id) }.to change(PageFetchWorker.jobs, :size).by(1)
  end

  describe PageFetchWorker do
    it { is_expected.to be_retryable 5 }
    it { is_expected.to save_backtrace }
  end
end