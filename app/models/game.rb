class Game < ApplicationRecord
  serialize :board, JSON
  serialize :stones, JSON
  @debug_text = ""

  def create_stones
    # create the stones
    symbols = ["a","b","c","x","y","z"]
    self.stones = []
    6.times do |color_nr|
      6.times do |symbol_nr|
        # for each color-symbol-combination there are two stones
        # when they are not on the board, their x,y is -1
        self.stones.push({"symbol" => symbols[symbol_nr], "color" => 1+color_nr, "x" => -1, "y" => -1 })
        self.stones.push({"symbol" => symbols[symbol_nr], "color" => 1+color_nr, "x" => -1, "y" => -1 })
      end
    end
    self.stones.shuffle!
    self.current_stone_id = 0
  end

  # place the next stone in the stones list on the board
  def place_stone(board_x, board_y)
    if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
      return
    end
    if self.current_stone_id < self.stones.length
      current_stone = self.stones[self.current_stone_id]
      current_stone["x"] = board_x
      current_stone["y"] = board_y
      self.board[board_x + 12 * board_y] = current_stone
      self.current_stone_id += 1
    end
  end

  def get_stone(board_x, board_y) # get stone or placeholder
    if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
      return nil
    end
    return self.board[board_x + 12 * board_y]
  end

  def get_current_stone # get next stone to be placed
    if self.current_stone_id  > 71
      return nil
    end
    return self.stones[self.current_stone_id]
  end

  def clear_board(board_x, board_y)
    if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
      return
    end
    self.board[board_x + 12 * board_y] = {"symbol" => "\u25CC", "color" => 0, "x" => board_x, "y" => board_y }
  end

  def undo_last_move
    if self.current_stone_id > 6 # the stones 1-6 are not placed by the player
      self.current_stone_id -= 1
      current_stone = self.stones[self.current_stone_id]
      board_x = current_stone["x"]
      board_y = current_stone["y"]
      # clear the board
      self.clear_board(board_x, board_y)
      current_stone["x"] = -1
      current_stone["y"] = -1
    end
  end

  # result: hash with "neighs","same_color","same_symbol"
  # returns false if color and symbol is different
  def compare_stone_with_current( stone, result )
    current_stone = self.stones[self.current_stone_id]
    if !stone || stone["color"] == 0
      return true # there are not two stones
    end
    if stone["color"] != current_stone["color"] && stone["symbol"] != current_stone["symbol"]
      return false
    end
    result[:neighs] += 1
    if stone["color"] == current_stone["color"]
      result[:same_color] += 1
    end
    if stone["symbol"] == current_stone["symbol"]
      result[:same_symbol] += 1
    end
    return true
  end

  # return 1,2,3,4: 1-to-4-way-fit  return 0: not fitting
  def current_stone_fit_count(board_x, board_y)
    if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
      return 0
    end
    # is there no stone left or a stone on this square?
    if self.current_stone_id >= 72 || self.get_stone(board_x, board_y)["color"] != 0
      return 0
    end

    # compare current stone with neighbours on four surrounding squares
    result = { neighs: 0, same_color: 0, same_symbol: 0}
    neigh_squares = []
    neigh_squares.push( { board_x: board_x - 1, board_y: board_y    }) if board_x > 0
    neigh_squares.push( { board_x: board_x + 1, board_y: board_y    }) if board_x < 11
    neigh_squares.push( { board_x: board_x    , board_y: board_y - 1}) if board_y > 0
    neigh_squares.push( { board_x: board_x    , board_y: board_y + 1}) if board_y < 7
    neigh_squares.each do |n|
      neigh_stone = self.get_stone(n[:board_x], n[:board_y])
      if !neigh_stone
        return 0
      end
      if !self.compare_stone_with_current(neigh_stone, result) # for each neighbour color or symbol has to be the same
        return 0
      end
    end

    # (for each neighbour color or symbol has to be the same)
    if result[:neighs] == 1 # one neighbour: same color or same symbol
      return 1
    elsif result[:neighs] == 4 # 4-way: two with same color, two with same symbol
      if result[:same_color] > 1 && result[:same_symbol] > 1
        return 4
      else
        return 0
      end
    else # 2,3 neighbours at least one with same color, at least one with with same symbol
      if result[:same_color] > 0 && result[:same_symbol] > 0
        return result[:neighs]
      else
        return 0
      end
    end
  end

  def set_debug_text text
    @debug_text = text
  end
  def clear_debug_text
    @debug_text = ""
  end
  def debug_text
    return @debug_text
  end
end
