require 'csv'
class Admin::EventRegistrationsController < AdminController
  before_action :require_editor!

  before_action :find_event

  def index
    @q = @event.registrations.ransack(params[:q])

    @registrations = @q.result.includes(:ticket).order("id DESC").page(params[:page]).per(10)

    if params[:registration_id].present?
      @registrations = @registrations.where( :id => params[:registration_id].split(","))
    end

    if params[:start_on].present?
      @registrations = @registrations.where("created_at >= ?", Date.parse(params[:start_on]).beginning_of_day )
    end

    if params[:end_on].present?
      @registrations = @registrations.where( "created_at <= ?", Date.parse(params[:end_on]).end_of_day )
    end

    if Array(params[:statuses]).any?
      @registrations = @registrations.by_status(params[:statuses])
    end

    if Array(params[:ticket_ids]).any?
      @registrations = @registrations.by_ticket(params[:ticket_ids])
    end

    if params[:status].present? && Registration::STATUS.include?(params[:status])
      @registrations = @registrations.by_status(params[:status])
    end

    if params[:ticket_id].present?
      @registrations = @registrations.by_ticket(params[:ticket_id])
    end

    respond_to do |format|
      format.html
      format.csv {
        @registrations = @registrations.reorder("id ASC")
        csv_string = CSV.generate do |csv|
          csv << ["报名ID", "票种", "姓名", "状态", "Email", "报名时间"]
          @registrations.each do |r|
            csv << [r.id, r.ticket.name, r.name, t(r.status, :scope => "registration.status"), r.email, r.created_at]
          end
        end
        send_data csv_string, :filename => "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.csv"
      }

      format.xlsx

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
      redirect_to admin_event_registrations_path(@event)
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
    params.require(:registration).permit(:status, :ticket_id, :name, :email, :cellphone, :website, :bio)
  end

  def require_editor!
    if current_user.role != "editor" && current_user.role != "admin"
      flash[:alert] = "You are not editor & admin!"
      redirect_to root_path
    end
  end





end
