require "net/http"

module UrlHelper

  def valid_url_format?(url)
    url && URI.parse(url) && url.match(/(https?|ftp):\/\//)
  end

  def is_existing_page?(url)
    return true if Rails.env == 'test'
    begin
      url = URI.parse(url)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url)
      res.code == "200"
    rescue
      false
    end
  end

end