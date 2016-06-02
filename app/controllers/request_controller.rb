class RequestController < ApplicationController
  include JobHelper
  include UrlHelper

  def job
    url = params[:url]
    if valid_url_format?(url)
      # .handle_job_request returns an array [job, page_resource] when it could be saved and nil-s when not
      job, page_resource = handle_job_request(url)
      render json: {job_id: job.id, job_status: job.status}
    else
      head :bad_request
    end
  end

  def status
    if params[:job_id]
      response = get_status_update(params[:job_id])
      if response
        render json: response
      else
        head :bad_request
      end
    end
  end
end