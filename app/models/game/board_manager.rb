class Game
  class BoardManager
    def initialize(my_game)
      @game = my_game
    end

    def create
      # set up the board with 12x8 empty squares
      #   symbols \u2218 : small circle,  \u2219 : small bullet, \u2217 : 6-star
      @game.board = (0..8*12).to_a
      8.times do |board_y|
        12.times do |board_x|
          self.clear_board(board_x, board_y)
        end
      end
    end

    def clear_board(board_x, board_y)
      if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
        return
      end

      @game.board[board_x + 12 * board_y] = {"symbol" => "\u25CC", "color" => 0, "x" => board_x, "y" => board_y, "fit_count" => 0 }
    end

    def get_stone(board_x, board_y) # get stone or placeholder
      if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
        return nil
      end

      return @game.board[board_x + 12 * board_y]
    end

    def place_stone( stone, board_x, board_y, fit_count=0)
      stone["x"] = board_x
      stone["y"] = board_y
      stone["fit_count"] = fit_count
      @game.four_count += 1 if fit_count==4
      @game.board[board_x + 12 * board_y] = stone
    end

    def take_stone_from_board(stone)
      board_x = stone["x"]
      board_y = stone["y"]
      self.clear_board(board_x, board_y)
      stone["x"] = -1
      stone["y"] = -1
    end

    # return 1,2,3,4: 1-to-4-way-fit  return 0: not fitting
    def fit_count(stone, board_x, board_y)
      if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
        return 0
      end

      # is there  a stone on this square?
      if self.get_stone(board_x, board_y)["color"] != 0
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

        if !self.compare_stones(neigh_stone, stone, result) # for each neighbour color or symbol has to be the same
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

    # result: hash with "neighs","same_color","same_symbol"
    # returns false if color and symbol is different
    def compare_stones(stone1, stone2, result )
      if !stone1 || stone1["color"] == 0 || !stone2 || stone2["color"] == 0
        return true # there are not two stones
      end

      if stone1["color"] != stone2["color"] && stone1["symbol"] != stone2["symbol"]
        return false
      end

      result[:neighs] += 1
      if stone1["color"] == stone2["color"]
        result[:same_color] += 1
      end

      if stone1["symbol"] == stone2["symbol"]
        result[:same_symbol] += 1
      end

      return true
    end

  end
end
