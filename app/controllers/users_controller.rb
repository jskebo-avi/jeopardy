class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter do
    redirect_to root_path unless current_user && current_user.admin?
  end

  def index
    @users = User.all
  end

	def edit
		@user = User.find(params[:id])
	end

  def update
		@user = User.find(params[:id])
		@user.update(user_params)
		redirect_to users_path
	end

  private

	def user_params
		params.require(:user).permit(:name, :email, :admin)
	end
end
