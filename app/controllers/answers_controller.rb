class AnswersController < ApplicationController
	def create
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.create(answer_params)
		redirect_to clue_path(@clue)
	end

	def destroy
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(:id)
		@answer.destroy
		redirect_to clue_path(@clue)

	private

	def answer_params
		params.require(:answer).permit(:user, :response, :wager, :status)
	end
end
