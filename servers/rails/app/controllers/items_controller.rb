class ItemsController < ApplicationController
  def index
    render formats: [:xml], stream: true
  end
end
