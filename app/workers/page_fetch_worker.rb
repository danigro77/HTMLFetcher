require 'open-uri'

class PageFetchWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, backtrace: true

  def perform(job_id)
    job = Job.find_by(id: job_id)
    page_resource = job.page_resource
    url = 'http://pablokohls.herokuapp.com'#resource.url
    request = Nokogiri::HTML(open(url))
    page_resource.update(html: request.inner_html)
    job.update(status: 'done')
  end

end