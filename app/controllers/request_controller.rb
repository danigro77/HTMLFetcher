class RequestController < ApplicationController
  include JobHelper
  include UrlHelper

  def job
    handle_failed_jobs
    url = params[:url].chomp.strip
    if valid_url_format?(url)
      # .handle_job_request returns an array [job, page_resource] when it could be saved and nil-s when not
      job, page_resource = handle_job_request(url)
      if job && page_resource
        unless job.status == 'done'
          jid = PageFetchWorker.perform_async(job.id)
          job.update(jid: jid)
        end
        response = {job_id: job.id, job_status: job.status, page_id: page_resource.id}
        response[:html] = page_resource.html if job.status == 'done'
        render json: response
      else
        head :not_found
      end
    else
      head :bad_request
    end
  end

  def status
    handle_failed_jobs
    if params[:job_id]
      response = get_status_update(params[:job_id])
      if response
        render json: response
      else
        head :not_found
      end
    else
      head :bad_request
    end
  end
end