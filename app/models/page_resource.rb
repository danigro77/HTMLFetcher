class PageResource < ActiveRecord::Base
  has_many :jobs

  validates_presence_of :url
  validate :url_format

  private

  def url_format
    uri = URI.parse(url) if url
    unless url && uri && url.match(/(https?|ftp):\/\//)
      errors.add(:request_url, 'is not valid')
    end
  end
end