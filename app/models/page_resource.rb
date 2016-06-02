class PageResource < ActiveRecord::Base
  include UrlHelper
  has_many :jobs

  validates_presence_of :url
  validate :url_format

  def update_populatiry
    pop = popularity+1
    self.update(popularity: pop) ? true : errors.add(:popularity, 'was not updated')
  end

  private

  def url_format
    unless valid_url_format?(url)
      errors.add(:request_url, 'is not valid')
    end
  end
end