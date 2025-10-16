class Public::IntakeController < Public::ApplicationController
  before_action :load_intake_data
  before_action :ensure_staff_team

  STEPS = %w[renting_business property_owner events].freeze

  def new
    redirect_to public_intake_step_path(step: "renting_business")
  end

  def show
    @step = params[:step]

    unless STEPS.include?(@step)
      redirect_to public_intake_step_path(step: "renting_business") and return
    end

    case @step
    when "renting_business"
      @client = Client.new(session[:intake_data][:client] || {})
    when "property_owner"
      @agreement = Agreement.new(session[:intake_data][:agreement] || {})
    when "events"
      @agreement = Agreement.new(session[:intake_data][:agreement] || {})
      # Pre-populate with at least one event
      if @agreement.events.empty?
        saved_events = session[:intake_data][:events] || []
        if saved_events.empty?
          @agreement.events.build
        else
          saved_events.each do |event_data|
            @agreement.events.build(event_data)
          end
        end
      end
    end

    render "public/intake/#{@step}"
  end

  def update
    @step = params[:step]

    unless STEPS.include?(@step)
      redirect_to public_intake_step_path(step: "renting_business") and return
    end

    case @step
    when "renting_business"
      session[:intake_data][:client] = client_params.to_h
      redirect_to public_intake_step_path(step: "property_owner")
    when "property_owner"
      session[:intake_data][:agreement] = agreement_params.to_h
      redirect_to public_intake_step_path(step: "events")
    when "events"
      # Save events to session
      if params[:agreement] && params[:agreement][:events_attributes]
        session[:intake_data][:events] = params[:agreement][:events_attributes].values.map(&:to_unsafe_h)
      end

      # Create all the records
      if create_intake_records
        # Clear session data
        session[:intake_data] = nil
        redirect_to public_intake_complete_path, notice: "Your intake form has been submitted successfully!"
      else
        @agreement = Agreement.new(session[:intake_data][:agreement] || {})
        # Rebuild events from params
        if params[:agreement] && params[:agreement][:events_attributes]
          params[:agreement][:events_attributes].each do |_key, event_attrs|
            @agreement.events.build(event_attrs) unless event_attrs[:_destroy] == "1"
          end
        end
        render "public/intake/events"
      end
    end
  end

  def complete
    # Success page after form submission
  end

  private

  def load_intake_data
    session[:intake_data] ||= {
      client: {},
      agreement: {},
      events: []
    }
  end

  def ensure_staff_team
    # All public intake clients belong to the staff team
    staff_team_id = ENV.fetch("STAFF_TEAM_ID", nil)

    if staff_team_id.present?
      @staff_team = Team.find(staff_team_id)
    else
      # Fallback: find the first team if STAFF_TEAM_ID is not set
      @staff_team = Team.first
      Rails.logger.warn "STAFF_TEAM_ID not set, using first team (#{@staff_team&.id})"
    end

    unless @staff_team
      redirect_to root_path, alert: "System configuration error. Please contact support."
    end
  end

  def client_params
    params.require(:client).permit(:business_name, :ein, :data)
  end

  def agreement_params
    params.require(:agreement).permit(:owner_name, :owner_email, :property_address, :year)
  end

  def events_params
    params.require(:agreement).permit(
      events_attributes: [:id, :event_type, :event_date_on, :_destroy]
    )
  end

  def create_intake_records
    ActiveRecord::Base.transaction do
      # Find or create client
      client_data = session[:intake_data][:client]
      @client = Client.find_or_initialize_by(ein: client_data["ein"])
      @client.assign_attributes(
        business_name: client_data["business_name"],
        team: @staff_team
      )
      @client.save!

      # Create agreement
      agreement_data = session[:intake_data][:agreement]
      current_year = Time.current.year
      @agreement = @client.agreements.create!(
        property_address: agreement_data["property_address"],
        year: agreement_data["year"] || current_year,
        status: "draft",
        owner_name: agreement_data["owner_name"],
        owner_email: agreement_data["owner_email"]
      )

      # Create events
      events_data = session[:intake_data][:events] || []
      events_data.each do |event_attrs|
        next if event_attrs["_destroy"] == "1" || event_attrs["_destroy"] == true
        next if event_attrs["event_type"].blank?

        @agreement.events.create!(
          event_type: event_attrs["event_type"],
          event_date_on: event_attrs["event_date_on"]
        )
      end

      true
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Intake form error: #{e.message}"
    false
  end
end
