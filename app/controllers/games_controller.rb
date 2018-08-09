class GamesController < ApplicationController
  before_action :set_game, only: [:show, :set_stone, :undo]
  load_and_authorize_resource
  def index
    if user_signed_in?
      @games = Game.where( user_id: current_user.id )
    else
      # guest games older than 2 days are removed
      Game.where("created_at < ?", 7.days.ago).destroy_all
      @games = []
    end
  end

  def show
  end

  def set_stone
    board_x = params[:board_x].to_i
    board_y = params[:board_y].to_i
    @game.place_stone(board_x, board_y)

    respond_to do |format|
      if @game.save
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

    if user_signed_in?
      @game.user_id = current_user.id
    else
      @game.user_id = 1  # guest user game
    end

    @game.name = ""
    (0...20).each {|n| @game.name += ('a'..'z').to_a.sample }

    @game.create_board
    @game.create_stones

    @game.score = 0;
    @game.four_count = 0;
    @game.undo_count = 0;

    #place the first six stones on the board
    @game.place_stone( 0,  0)
    @game.place_stone(11,  0)
    @game.place_stone( 0,  7)
    @game.place_stone(11,  7)
    @game.place_stone( 5,  3)
    @game.place_stone( 6,  4)

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
