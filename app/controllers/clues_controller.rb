class CluesController < ApplicationController
	http_basic_authenticate_with name: "admin", password: "trebek", except: :show
	def index
		@clues = Clue.all#of_week(Date.today)
	end

	def show
		@clue = Clue.find(params[:id])
	end

	def new
		@clue = Clue.new
		defSeq = Clue.where("week = ?", Date.today.beginning_of_week).maximum(:seq)
		if defSeq.nil? then defSeq = 10 else defSeq += 10 end
		@clue.seq = defSeq
		@clue.week = Date.today
	end

	def edit
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
			redirect_to @clue
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
		params.require(:clue).permit(:category, :text, :value, :final, :week, :seq)
	end
end
