class Game < ApplicationRecord
  include ActionView::Helpers
  belongs_to :user
  serialize :board, JSON
  serialize :stones, JSON

  after_initialize do |game|
    @board = BoardManager.new(game)
    @stones = StonesManager.new(game)
  end

  after_find do |game|
    @board ||= BoardManager.new(game)
    @stones ||= StonesManager.new(game)
  end

  def init
    self.name = ""
    (0...20).each {|n| self.name += ('a'..'z').to_a.sample }

    @board.create
    @stones.create

    @board.place_stone(@stones.go_to_next_stone, 0,  0)
    @board.place_stone(@stones.go_to_next_stone,11,  0)
    @board.place_stone(@stones.go_to_next_stone, 0,  7)
    @board.place_stone(@stones.go_to_next_stone,11,  7)
    @board.place_stone(@stones.go_to_next_stone, 5,  3)
    @board.place_stone(@stones.go_to_next_stone, 6,  4)
  end


  # place the next stone in the stones list on the board
  def place_stone(board_x, board_y)
    if @stones.all_stones_set?
      return  true  #there are no stones left to be palced
    end

    current_stone = @stones.get_current_stone
    fit_count = @board.fit_count(current_stone, board_x, board_y)
    if fit_count < 1
      return true  # we are not allowed to place a stone there
    end

    self.score += @stones.calculate_score( fit_count )
    @board.place_stone( @stones.go_to_next_stone, board_x, board_y, fit_count)
    return self.save
  end

  def get_stone(board_x, board_y)
    @board.get_stone(board_x, board_y)
  end

  def get_current_stone # get next stone to be placed
    @stones.get_current_stone
  end

  def undo_last_move
    if @stones.before_first_move? # nothing to undo
      return true
    end

    current_stone = @stones.back_to_previous_stone
    @board.take_stone_from_board(current_stone)
    return self.save
  end

  def current_stone_fit_count(board_x, board_y)
    if @stones.all_stones_set? # there is no current stone
      return 0
    end

    return @board.fit_count( @stones.get_current_stone, board_x, board_y)
  end

  # depending on previous undo_last_move
  # points are reduced after undo
  def undo_penalty
    return 2 ** self.undo_count
  end
end
