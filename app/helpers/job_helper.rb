module JobHelper
  def handle_job_request(url)
    page_resource = PageResource.find_by(url: url)
    resource_date = page_resource.try(:updated_at).try(:utc)
    case
      when resource_date.nil? # page was never requested before
        create_request(url)
      when resource_date < DateTime.current.end_of_day # page request is old and needs updating
        update_request(page_resource)
      else # page request is recent and can be reused
        reuse_request(page_resource)
    end # returns an array [job, page_resource] when it could be saved and nil when not
  end

  def get_status_update(job_id)
    job = Job.find_by(id: job_id)
    if job
      response = {status: job.status}
      response[:html] = job.page_resource.html if job.status == 'done'
      response[:message] = I18n.t("status_messages.#{job.status.to_s}") || "Unknown action" unless job.status == 'done'
    else
      response = nil
    end
    response
  end

  private

  def create_request(url) # when new
    page_resource = PageResource.new(url: url)
    if page_resource.save
      [create_job(page_resource, :creating), page_resource]
    else
      [nil, nil]
    end
  end

  def update_request(page_resource)
    if page_resource.update_populatiry
      [create_job(page_resource, :updating), page_resource]
    else
      [nil, nil]
    end
  end

  def reuse_request(page_resource)
    [create_job(page_resource, :done), page_resource]
  end

  def create_job(page_resource, status)
    job = Job.new(page_resource:page_resource, status: status)
    job.save ? job : nil
  end

end