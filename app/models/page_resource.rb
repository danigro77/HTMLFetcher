class PageResource < ActiveRecord::Base
  include UrlHelper
  has_many :jobs

  validates_presence_of :url
  validates_uniqueness_of :url
  validate :url_format, :existing_page

  scope :sort_by_popularity, -> { order('popularity DESC') }

  def latest_job
    jobs.order(:updated_at).last
  end

  def last_creating_job
    jobs.select {|e| e.status == "creating"}.sort_by(&:updated_at).last
  end

  def update_popularity
    pop = popularity+1
    self.update(popularity: pop) ? true : errors.add(:popularity, 'was not updated')
  end

  def needs_updating?
    has_done_jobs? && is_outdated?
  end

  def is_outdated?
    updated_at.utc < DateTime.current.beginning_of_day
  end

  Job::JOB_STATUS.each do |key, value|
    define_method("has_#{key}_jobs?") do
      jobs.pluck(:status).include?(value)
    end
  end

  private

  def url_format
    unless valid_url_format?(url)
      errors.add(:url, 'is not valid')
    end
  end

  def existing_page
    unless is_existing_page?(url)
      errors.add(:url, 'has no page.')
    end
  end
end