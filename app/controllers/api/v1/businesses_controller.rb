class Api::V1::BusinessesController < Api::V1::ApplicationController
  account_load_and_authorize_resource :business, through: :team, through_association: :businesses

  # GET /api/v1/teams/:team_id/businesses
  def index
  end

  # GET /api/v1/businesses/:id
  def show
  end

  # POST /api/v1/teams/:team_id/businesses
  def create
    if @business.save
      render :show, status: :created, location: [:api, :v1, @business]
    else
      render json: @business.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/businesses/:id
  def update
    if @business.update(business_params)
      render :show
    else
      render json: @business.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/businesses/:id
  def destroy
    @business.destroy
  end

  private

  module StrongParameters
    # Only allow a list of trusted parameters through.
    def business_params
      strong_params = params.require(:business).permit(
        *permitted_fields,
        :name,
        :description,
        :funnel_url,
        :app_url,
        # 🚅 super scaffolding will insert new fields above this line.
        *permitted_arrays,
        # 🚅 super scaffolding will insert new arrays above this line.
      )

      process_params(strong_params)

      strong_params
    end
  end

  include StrongParameters
end
