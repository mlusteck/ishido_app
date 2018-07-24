class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    if(Game.exists?(params[:id]))
      @game = Game.find(params[:id])
    else
      @game = nil
    end
  end

  def new
    @game = Game.new
    if @game.save
      redirect_to @game, notice: 'Game was successfully created.' 
    else
      redirect_to games_path, notice: 'An Error occurred. Game was not created.'
    end
  end

  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:board)
    end
end
