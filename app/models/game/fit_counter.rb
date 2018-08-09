class Game
  class FitCounter
    def initialize(my_game)
      @game = my_game
    end

    # return 1,2,3,4: 1-to-4-way-fit  return 0: not fitting
    def current_stone_fit_count(board_x, board_y)
      if board_x < 0 || board_y < 0 || board_x > 11 || board_y > 7
        return 0
      end

      # is there no stone left or a stone on this square?
      if @game.current_stone_id >= 72 || @game.get_stone(board_x, board_y)["color"] != 0
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
        neigh_stone = @game.get_stone(n[:board_x], n[:board_y])
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

    # result: hash with "neighs","same_color","same_symbol"
    # returns false if color and symbol is different
    def compare_stone_with_current( stone, result )
      current_stone = @game.stones[@game.current_stone_id]
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

  end
end
