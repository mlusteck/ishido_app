class GamesController < ApplicationController
  def index
    if user_signed_in?
      @games = Game.where( user_id: current_user.id )
    else
      # guest games older than 2 days are removed
      Game.where("created_at < ?", 2.days.ago).destroy_all

      @games = Game.where( user_id: 1 )
      # @games = []
    end
  end

  def show
    @game = Game.find_by(id: params[:id])
    if(@game.name != params[:name])
      respond_to do |format|
        format.html { redirect_to games_path, alert: 'Wrong game name.'  }
        format.json { render :show, status: :ok, location: games_path }
      end
    end
  end

  def set_stone
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

    board_x = params[:board_x].to_i
    board_y = params[:board_y].to_i
    @game.place_stone(board_x, board_y)

    respond_to do |format|
      if @game.save
        format.html { redirect_to game_path(@game, name: @game.name), notice: params[:name] + 'Stone was placed at (' + params[:board_x] + ', ' + params[:board_y] + ')' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { redirect_to game_path(@game, name: @game.name), alert: 'An Error occurred.' }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def undo
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

    @game.undo_last_move
    respond_to do |format|
      if @game.save
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
    @game.name = ""
    (0...10).each {|n| @game.name += ('a'..'z').to_a.sample }

    # set up the board with 12x8 empty squares
    #   symbols \u2218 : small circle,  \u2219 : small bullet, \u2217 : 6-star
    @game.board = (0..8*12).to_a
    8.times do |board_y|
      12.times do |board_x|
        @game.clear_board(board_x, board_y)
      end
    end

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

    if user_signed_in?
      @game.user_id = current_user.id
    else
      @game.user_id = 1  # guest user game
    end

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
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:board_x, :board_y)
    end
end
