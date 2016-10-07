class AnswersController < ApplicationController
	def create
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.new(answer_params)
		@answer.status = :pending
		@answer.save
		redirect_to clue_path(@clue)
	end
=begin
	def update
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(:id)
		@answer.update(answer_params)
		respond_to do |format|
		    format.html { redirect_to clues_url }
		    format.json { head :no_content }
		    format.js   { render :layout => false }
		end
	end
=end
	def destroy
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(:id)
		@answer.destroy
		redirect_to clue_path(@clue)
	end

	def correct
		@clue = Clue.find(params[:clue])
		@answer = @clue.answers.find(params[:answer])
		@answer.status = :correct
		@answer.save
		respond_to do |format|
		    format.js   { render json: { test: 1 } }
		    format.html { redirect_to clues_url }
		end
	end

	private

	def answer_params
		params.require(:answer).permit(:user, :response, :wager, :status)
	end
end
