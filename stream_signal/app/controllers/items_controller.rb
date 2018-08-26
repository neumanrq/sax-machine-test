class ItemsController < ApplicationController
  def index
    render formats: [:xml]
  end
end
