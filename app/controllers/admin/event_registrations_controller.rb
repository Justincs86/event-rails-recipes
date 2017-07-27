class Admin::EventRegistrationsController < AdminController
  before_action :find_event

  def index
    @registrations = @event.registrations.includes(:ticket).order("id DESC").page(params[:page]).per(10)

    if params[:status].present? && Registration::STATUS.include?(params[:status])
      @registrations = @registrations.by_status(params[:status])
    end

    if params[:ticket_id].present?
      @registrations = @registions.by_ticket(params[:ticket_id])
    end
    
  end

  def new
    @registration = @event.registrations.new
  end

  def create
    @registration = @event.registrations.new(registration_params)
    @registration.ticket_id = params[:registration][:ticket_id]
    if @registration.save
      redirect_to admin_event_registrations_path(@event)
    else
      render "new"
    end
  end

  def edit
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def update
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.ticket_id = params[:registration][:ticked_id]

    if @registration.update(registration_params)
      redirect_to admin_event_registration_path(@event)
    else
      render "edit"
    end
  end



  def destroy
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.destroy

    flash[:alert] = "Deleted"
    redirect_to admin_event_registrations_path(@event)
  end


  protected

  def find_event
    @event = Event.find_by_friendly_id!(params[:event_id])
  end

  def registration_params
    params.require(:registration).permit(:status, :ticket, :name, :email, :cellphone, :website, :bio)
  end


end
