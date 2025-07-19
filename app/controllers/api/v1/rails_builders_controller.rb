# Api::V1::ApplicationController is in the starter repository and isn't
# needed for this package's unit tests, but our CI tests will try to load this
# class because eager loading is set to `true` when CI=true.
# We wrap this class in an `if` statement to circumvent this issue.
if defined?(Api::V1::ApplicationController)
  class Api::V1::RailsBuildersController < Api::V1::ApplicationController
    account_load_and_authorize_resource :rails_builder, through: :team, through_association: :rails_builders

    # GET /api/v1/teams/:team_id/rails_builders
    def index
    end

    # GET /api/v1/rails_builders/:id
    def show
    end

    # POST /api/v1/teams/:team_id/rails_builders
    def create
      if @rails_builder.save
        render :show, status: :created, location: [:api, :v1, @rails_builder]
      else
        render json: @rails_builder.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/rails_builders/:id
    def update
      if @rails_builder.update(rails_builder_params)
        render :show
      else
        render json: @rails_builder.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/rails_builders/:id
    def destroy
      @rails_builder.destroy
    end

    private

    module StrongParameters
      # Only allow a list of trusted parameters through.
      def rails_builder_params
        strong_params = params.require(:rails_builder).permit(
          *permitted_fields,
          :first_name,
          :last_name,
          :email,
          :builder_level_id,
          :bio_image,
          :bio_image_removal,
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
else
  class Api::V1::RailsBuildersController
  end
end
