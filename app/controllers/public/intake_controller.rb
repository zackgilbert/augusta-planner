class Public::IntakeController < Public::ApplicationController
  before_action :ensure_staff_team
  before_action :load_or_create_draft, only: [:show, :update]

  STEPS = %w[business property events].freeze

  def new
    # Clear any previous draft session
    session[:intake_draft_id] = nil
    redirect_to public_intake_step_path(step: "business")
  end

  def show
    @step = params[:step]

    unless STEPS.include?(@step)
      redirect_to public_intake_step_path(step: "business")
      return
    end

    case @step
    when "business"
      @client = @draft_client
    when "property", "events"
      @agreement = @draft_agreement
      
      # If no draft agreement exists (e.g., session was cleared), redirect to start
      unless @agreement
        redirect_to public_intake_path
        return
      end
      
      # Pre-populate with at least one event for events step
      if @step == "events" && @agreement.events.empty?
        @agreement.events.build
      end
    end

    render "public/intake/#{@step}"
  end

  def update
    @step = params[:step]

    unless STEPS.include?(@step)
      redirect_to public_intake_step_path(step: "business")
      return
    end

    # Determine if user clicked back button
    going_back = params[:commit] == "Back" || params[:direction] == "back"

    case @step
    when "business"
      if params[:client].present? && !going_back
        # Find or create client by EIN
        ein = client_params[:ein]
        existing_client = Client.find_by(ein: ein)
        
        if existing_client
          # Use existing client, don't modify it
          @draft_client = existing_client
        else
          # Create new client
          @draft_client.assign_attributes(client_params)
          unless @draft_client.save
            @client = @draft_client
            render "public/intake/business"
            return
          end
        end
        
        # Find or create draft agreement
        current_year = Time.current.year
        @draft_agreement = @draft_client.agreements.find_or_initialize_by(year: current_year) do |agreement|
          agreement.status = "intake_draft"
        end
        
        # If agreement exists but is not a draft, reset it to draft for re-submission
        if @draft_agreement.persisted? && !@draft_agreement.intake_draft?
          @draft_agreement.status = "intake_draft"
        end
        
        # Save the agreement if it's new or modified
        unless @draft_agreement.save
          @client = @draft_client
          flash[:alert] = "Unable to create agreement: #{@draft_agreement.errors.full_messages.join(', ')}"
          render "public/intake/business" and return
        end
        
        session[:intake_draft_id] = @draft_agreement.id
      end
      
      if going_back
        redirect_to public_intake_path
      else
        redirect_to public_intake_step_path(step: "property")
      end
      
    when "property"
      if params[:agreement].present? && !going_back
        @draft_agreement.assign_attributes(agreement_params)
        unless @draft_agreement.save
          @agreement = @draft_agreement
          render "public/intake/property"
          return
        end
      end
      
      if going_back
        redirect_to public_intake_step_path(step: "business")
      else
        redirect_to public_intake_step_path(step: "events")
      end
      
    when "events"
      if going_back
        redirect_to public_intake_step_path(step: "property")
      else
        # Update events and finalize
        if params[:agreement].present?
          @draft_agreement.assign_attributes(events_params)
        end
        
        # Change status from draft to submitted
        @draft_agreement.status = "pending_review"
        
        if @draft_agreement.save
          # Keep session active so user can view what they submitted
          redirect_to public_intake_complete_path, notice: "Your intake form has been submitted successfully!"
        else
          @agreement = @draft_agreement
          render "public/intake/events"
        end
      end
    end
  end

  def complete
    # Success page after form submission
  end

  private

  def load_or_create_draft
    if session[:intake_draft_id].present?
      @draft_agreement = Agreement.find_by(id: session[:intake_draft_id], status: "intake_draft")
      @draft_client = @draft_agreement&.client
    end
    
    # Create new draft client if none exists
    @draft_client ||= Client.new(team: @staff_team)
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
    params.require(:client).permit(:business_name, :ein)
  end

  def agreement_params
    params.require(:agreement).permit(:owner_name, :owner_email, :property_address, :property_bedrooms, :year)
  end

  def events_params
    params.require(:agreement).permit(
      events_attributes: [:id, :event_type, :event_date_on, :_destroy]
    )
  end
end
