class Public::BuilderLevelsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  
  def index
    @builder_levels = BuilderLevel.order(:id)
  end
end
