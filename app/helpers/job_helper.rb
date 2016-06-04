require 'sidekiq/api'

module JobHelper
  def handle_job_request(url)
    page_resource = PageResource.find_by(url: url)
    resource_date = page_resource.try(:updated_at).try(:utc)
    case
      when resource_date.nil? # page was never requested before
        create_request(url)
      when page_resource.needs_updating? # request has done jobs and was not called within this day
        update_request(page_resource)
      when page_resource.has_done_jobs? && page_resource.latest_job.status == 'done' # page request is recent and can be reused
        reuse_request(page_resource)
      else
        resend_request(page_resource)
    end # returns an array [job, page_resource] when it could be saved and nil when not
  end

  def get_status_update(job_id)
    job = Job.find_by(id: job_id)
    if job
      response = {status: job.status, job_id: job_id, page_id: job.page_resource.id}
      response[:html] = job.page_resource.html if job.status == 'done'
      response[:message] = I18n.t("status_messages.#{job.status.to_s}") || "Unknown action" unless job.status == 'done'
    else
      response = nil
    end
    response
  end

  def handle_failed_jobs
    ds = Sidekiq::DeadSet.new
    jobs = Job.all_creating
    jobs.each do |job|
      if ds.size > 0 && ds.find_job(job.jid)
        job.update(status: 'failed')
      end
    end
    ds.clear
  end

  private

  def create_request(url) # when new
    page_resource = PageResource.new(url: url)
    if page_resource.save
      [create_job(page_resource, 'creating'), page_resource]
    else
      [nil, nil]
    end
  end

  def resend_request(page_resource)
    case
      when page_resource.has_creating_jobs?
        job = page_resource.last_creating_job
      when page_resource.has_failed_jobs? && page_resource.is_existing_page?(page_resource.url)
        job = create_job(page_resource, 'updating')
      else
        job = nil
      end
    [job, page_resource]
  end

  def update_request(page_resource)
    update_and_reuse(page_resource, 'updating')
  end

  def reuse_request(page_resource)
    update_and_reuse(page_resource, 'done')
  end

  def update_and_reuse(page_resource, status)
    if page_resource.update_popularity
      [create_job(page_resource, status), page_resource]
    else
      [nil, nil]
    end
  end

  def create_job(page_resource, status)
    job = Job.new(page_resource:page_resource, status: status)
    job.save ? job : nil
  end

end