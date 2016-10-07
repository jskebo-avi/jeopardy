class AnswersController < ApplicationController
	def create
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.new(answer_params)
		@answer.status = 0
		@answer.save
		redirect_to clue_path(@clue)
	end

	def destroy
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(:id)
		@answer.destroy
		redirect_to clue_path(@clue)
	end

	def evaluate
		@clue = Clue.find(params[:clue])
		@answer = @clue.answers.find(params[:answer])
		@answer.status = params[:status]
		@answer.save
		respond_to do |format|
		    format.js   { render json: { new_user_score: @answer.user_current_score } }
		    format.html { redirect_to clues_url }
		end
	end

	def get_user_score
		@answer = Answer.find(params[:answer])
		respond_to do |format|
		    format.js   { render json: { user_score: @answer.user_current_score } }
		end
	end

	private

	def answer_params
		params.require(:answer).permit(:user, :response, :wager, :status)
	end
end
