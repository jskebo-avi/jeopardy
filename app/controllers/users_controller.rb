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
    @wins = @user.win_count
    @win_pct = @user.win_pct*100
    @longest_streak = @user.longest_streak
    @answers_count = @user.answers_count(false, false)
    @answers_correct = @user.answers_count(true, false)
    @answer_correct_pct = (@answers_correct.to_f/@answers_count)*100
    @correct_consec = @user.correct_consecutive(false)
    @answers_count_z = @user.answers_count(false, true)
    @answers_correct_z = @user.answers_count(true, true)
    @answer_correct_pct_z = (@answers_correct_z.to_f/@answers_count_z)*100
    @correct_consec_z = @user.correct_consecutive(true)
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
