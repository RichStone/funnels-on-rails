class Public::RailsBuildersController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    @rails_builders = RailsBuilder.joins(:participations)
      .where(participations: {left_at: nil})
      .includes(:builder_level, :participations, bio_image_attachment: :blob)
      .distinct
      .order(:first_name, :last_name)
  end
end
