class Job < ActiveRecord::Base
  belongs_to :page_resource

  JOB_STATUS = {received: 0, updating:1, creating: 2, done: 3, failed: 4}

  enum status: JOB_STATUS

  scope :all_creating, -> { where(status: 2) }
  scope :all_not_failed, -> { where.not(status: 4) }

end