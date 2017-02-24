class CluesController < ApplicationController
	#http_basic_authenticate_with name: "admin", password: "trebek", except: :show
	before_filter :authenticate_user!
	before_filter do
		redirect_to root_path unless current_user && current_user.admin?
	end

	def index
		@day = Date.parse(params[:day])
		@clues = Clue.all.eager_load(answers: :user).of_week(@day)
		@prev_week = @day.beginning_of_week - 7
		@next_week = @day.beginning_of_week + 7
	end

	def show
		@clue = Clue.find(params[:id])
	end

	def new
		@day = Date.parse(params[:day])
		lastClue = Clue.where("week = ?", @day.beginning_of_week).order(:seq).last
		defSeq = lastClue.nil? ? Clue::Default_seq : lastClue.seq += Clue::Default_seq
		defCat = lastClue.nil? ? "" : lastClue.category

		@clue = Clue.new
		@clue.seq = defSeq
		@clue.category = defCat
		@clue.week = @day.beginning_of_week
	end

	def edit
		@day = Date.parse(params[:day])
		@clue = Clue.find(params[:id])
	end

	def create
		@clue = Clue.new(clue_params)
		if @clue.save
			redirect_to clues_path
		else
			render 'new'
		end
	end

	def update
		@clue = Clue.find(params[:id])
		if @clue.update(clue_params)
			redirect_to clues_path
		else
			render 'edit'
		end
	end

	def destroy
		@clue = Clue.find(params[:id])
		@clue.destroy
		redirect_to clues_path
	end

	private

	def clue_params
		params.require(:clue).permit(:category, :text, :value, :final, :week, :seq, :correct_answer)
	end
end
