class RequestController < ApplicationController
  include JobHelper
  include UrlHelper

  def job
    handle_failed_jobs
    url = params[:url]
    if valid_url_format?(url)
      # .handle_job_request returns an array [job, page_resource] when it could be saved and nil-s when not
      job, page_resource = handle_job_request(url)
      if job && page_resource
        jid = PageFetchWorker.perform_async(job.id)
        job.update(jid: jid)
        render json: {job_id: job.id, job_status: job.status}
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