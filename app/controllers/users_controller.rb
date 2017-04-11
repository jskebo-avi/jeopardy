class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action except: [:show] do
    redirect_to root_path unless current_user && current_user.admin?
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

	def edit
		@user = User.find(params[:id])
	end

  def update
		@user = User.find(params[:id])
		@user.update(user_params)
		redirect_to users_path
  end

  def change_password
    @user = User.find(params[:user])
    encrypted_pw = User.new(password: params[:pw]).encrypted_password
    @user.encrypted_password = encrypted_pw
    @user.save
    respond_to do |format|
	    format.js   { render json: {redirect_path: users_path} }
	    format.html { redirect_to users_path }
		end
  end

  private

	def user_params
		params.require(:user).permit(:name, :email, :admin)
	end
end
