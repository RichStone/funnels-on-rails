class Account::RailsBuildersController < Account::ApplicationController
  account_load_and_authorize_resource :rails_builder, through: :team, through_association: :rails_builders

  # GET /account/teams/:team_id/rails_builders
  # GET /account/teams/:team_id/rails_builders.json
  def index
    delegate_json_to_api
  end

  # GET /account/rails_builders/:id
  # GET /account/rails_builders/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/rails_builders/new
  def new
  end

  # GET /account/rails_builders/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/rails_builders
  # POST /account/teams/:team_id/rails_builders.json
  def create
    respond_to do |format|
      if @rails_builder.save
        format.html { redirect_to [:account, @rails_builder], notice: I18n.t("rails_builders.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @rails_builder] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rails_builder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/rails_builders/:id
  # PATCH/PUT /account/rails_builders/:id.json
  def update
    respond_to do |format|
      if @rails_builder.update(rails_builder_params)
        format.html { redirect_to [:account, @rails_builder], notice: I18n.t("rails_builders.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @rails_builder] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rails_builder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/rails_builders/:id
  # DELETE /account/rails_builders/:id.json
  def destroy
    @rails_builder.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team, :rails_builders], notice: I18n.t("rails_builders.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
