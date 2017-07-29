class Admin::UsersController < AdminController
  before_action :require_admin!

  def index
    @users = User.includes(:groups).all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_users_path
    else
      render "edit"
    end
  end

  protected

  def user_params
    params.require(:user).permit(:email, :role, :group_ids => [])
  end

  def require_admin!
    if current_user.role != "admin"
      flash[:alert] = "You are not admin!"
      redirect_to root_path
    end
  end


end
