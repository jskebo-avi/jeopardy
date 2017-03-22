class AnswersController < ApplicationController
	def edit
		@day = Date.parse(params[:day])
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(params[:id])
	end

	def create
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.new(answer_params)
		@answer.user_id = current_user.id
		@answer.status = 0
		@answer.score = 0
		if @answer.response.respond_to? :strip
			@answer.response = @answer.response.strip()
		end
		@answer.save
		redirect_to root_path
	end

	def update
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(params[:id])
		@answer.update(answer_params)
		if params[:admin_update]
			redirect_to clues_path(day: @clue.week)
		else
			redirect_to root_path
		end
	end

	def destroy
		@clue = Clue.find(params[:clue_id])
		@answer = @clue.answers.find(params[:id])
		@answer.destroy
		respond_to do |format|
	    format.js   {}
	    format.html { redirect_to clues_url }
		end
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
	    format.js   { render json: { new_user_score: @clue.user_current_score(@answer.user_id) } }
	    format.html { redirect_to clues_url }
		end
	end

	def get_user_score
		@answer = Answer.find(params[:answer])
		@clue = Clue.find(@answer.clue_id)
		respond_to do |format|
		    format.js   { render json: { score: @clue.user_current_score(@answer.user_id), prev_score: @clue.user_previous_score(@answer.user_id) } }
		end
	end

	private

	def answer_params
		params.require(:answer).permit(:user_id, :response, :wager, :status, :score)
	end
end
