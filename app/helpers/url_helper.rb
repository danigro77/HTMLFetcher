module UrlHelper

  def valid_url_format?(url)
    url && URI.parse(url) && url.match(/(https?|ftp):\/\//)
  end

end