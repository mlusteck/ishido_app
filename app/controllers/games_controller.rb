class GamesController < ApplicationController
  before_action :set_game, only: [:show, :set_stone, :undo]
  load_and_authorize_resource
  def index
    if user_signed_in?
      @games = Game.where( user_id: current_user.id )
    else
      # guest games left alone more than 7 days are removed
      Game.where("updated_at < ?", 7.days.ago).destroy_all
      @games = []
    end
  end

  def show
  end

  def set_stone
    board_x = params[:board_x].to_i
    board_y = params[:board_y].to_i

    respond_to do |format|
      if @game.place_stone(board_x, board_y)
        if @game.score > 0
          helpers.insert_score @game.score, @game.user, @game.name
        end

        format.html { redirect_to game_path(@game, name: @game.name) }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { redirect_to game_path(@game, name: @game.name), alert: 'An Error occurred.' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def undo
    respond_to do |format|
      if @game.undo_last_move
        format.html { redirect_to game_path(@game, name: @game.name), notice: 'Undo.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { redirect_to game_path(@game, name: @game.name), alert: 'An Error occurred.'  }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @game = Game.new
    @game.init

    if user_signed_in?
      @game.user_id = current_user.id
    else
      @game.user_id = 1  # guest user game
    end

    session[:current_game_name] = @game.name

    respond_to do |format|
      if @game.save
        format.html { redirect_to game_path(@game, name: @game.name), notice: 'Game was successfully created.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { redirect_to games_path, alert: 'An Error occurred. Game was not created.' }
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
      @game = Game.find_by(id: params[:id])
      if(!@game)
        respond_to do |format|
          format.html { redirect_to games_path, alert: 'An Error occurred.'  }
          format.json { render :show, status: :ok, location: games_path }
        end
        return
      elsif (@game.name != params[:name])
        respond_to do |format|
          format.html { redirect_to games_path, alert: 'Wrong game name.'  }
          format.json { render :show, status: :ok, location: games_path }
        end
        return
      end

      session[:current_game_name] = @game.name
      if user_signed_in? && @game.user_id == 1
        @game.user_id = current_user.id
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:board_x, :board_y)
    end
end
