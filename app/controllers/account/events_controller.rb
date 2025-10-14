class Account::EventsController < Account::ApplicationController
  account_load_and_authorize_resource :event, through: :agreement, through_association: :events

  # GET /account/agreements/:agreement_id/events
  # GET /account/agreements/:agreement_id/events.json
  def index
    delegate_json_to_api
  end

  # GET /account/events/:id
  # GET /account/events/:id.json
  def show
    delegate_json_to_api
  end

  # GET /account/agreements/:agreement_id/events/new
  def new
  end

  # GET /account/events/:id/edit
  def edit
  end

  # POST /account/agreements/:agreement_id/events
  # POST /account/agreements/:agreement_id/events.json
  def create
    respond_to do |format|
      if @event.save
        format.html { redirect_to [:account, @event], notice: I18n.t("events.notifications.created") }
        format.json { render :show, status: :created, location: [:account, @event] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account/events/:id
  # PATCH/PUT /account/events/:id.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to [:account, @event], notice: I18n.t("events.notifications.updated") }
        format.json { render :show, status: :ok, location: [:account, @event] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account/events/:id
  # DELETE /account/events/:id.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to [:account, @agreement, :events], notice: I18n.t("events.notifications.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  if defined?(Api::V1::ApplicationController)
    include strong_parameters_from_api
  end

  def process_params(strong_params)
    assign_date(strong_params, :event_date_on)
    # 🚅 super scaffolding will insert processing for new fields above this line.
  end
end
