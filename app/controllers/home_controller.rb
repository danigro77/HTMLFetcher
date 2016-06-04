class HomeController < ApplicationController
  def index
    @page_resources = PageResource.sort_by_popularity
  end
end