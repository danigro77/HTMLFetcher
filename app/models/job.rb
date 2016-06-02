class Job < ActiveRecord::Base
  belongs_to :page_resource

  enum status: {received: 0, updating:1, creating: 2, done: 3, failed: 4}

end