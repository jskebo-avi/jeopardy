class AnswersController < ApplicationController
	def create
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.new(answer_params)
		@answer.status = 0
		@answer.score = 0
		@answer.save
		redirect_to root_path
	end

	def destroy
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(:id)
		@answer.destroy
		respond_to do |format|
		    format.js   {}
		    format.html { redirect_to clues_url }
	end

	def evaluate
		@clue = Clue.find(params[:clue])
		@answer = @clue.answers.find(params[:answer])
		@answer.status = params[:status]
		if @clue.final then
			if params[:status] == 1 then
				@answer.score = @answer.wager
			else
				@answer.score = -@answer.wager
			end
		else
			@answer.score = params[:status] == 1 ? @clue.value : 0
		end
		@answer.save
		respond_to do |format|
		    format.js   { render json: { new_user_score: @answer.user_current_score } }
		    format.html { redirect_to clues_url }
		end
	end

	def get_user_score
		@answer = Answer.find(params[:answer])
		respond_to do |format|
		    format.js   { render json: { score: @answer.user_current_score, prev_score: @answer.user_previous_score } }
		end
	end

	private

	def answer_params
		params.require(:answer).permit(:user, :response, :wager, :status, :score)
	end
end
