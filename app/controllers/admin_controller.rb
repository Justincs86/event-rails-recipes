class AdminController < ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  layout "admin"

  protected

  def require_editor!
    unless current_user.role.is_editor?
      flash[:alert] = "You are not editor & admin!"
      redirect_to root_path
    end
  end

  def require_admin!
    unless current_user.role.is_admin?
      flash[:alert] = "You are not admin!"
      redirect_to root_path
    end
  end


end
