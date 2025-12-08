class Account::BusinessesController < Account::ApplicationController
  account_load_and_authorize_resource :business, through: :team, through_association: :businesses

  # GET /account/businesses/:id
  # GET /account/businesses/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/teams/:team_id/businesses/new
  def new
  end

  # GET /account/businesses/:id/edit
  def edit
  end

  # POST /account/teams/:team_id/businesses
  # POST /account/teams/:team_id/businesses.json
  def create
    respond_to do |format|
      if @business.save
        format.html { redirect_to [:account, @team], notice: I18n.t("businesses.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @business] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/businesses/:id
  # PATCH/PUT /account/businesses/:id.json
  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to [:account, @team], notice: I18n.t("businesses.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @business] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/businesses/:id
  # DELETE /account/businesses/:id.json
  def destroy
    @business.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @team], notice: I18n.t("businesses.notifications.destroyed") }
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
