class Game < ApplicationRecord
  include ActionView::Helpers
  belongs_to :user
  serialize :board, JSON
  serialize :stones, JSON

  def create_stones
    # create the stones
    #symbols = ["a","b","c","x","y","z"].shuffle
    symbols = ["\u03C8","\u03B2","\u03B1","\u03B4","\u03BE","\u03C9"].shuffle # greek letters
    colors  = [1, 2, 3, 4, 5, 6].shuffle
    self.stones = []
    first_stones = []  # all colors and symbols have to be present in the first 6 stones
    other_stones = []  # thus we have to pick those into first_stones and shuffle only the other_stones
    6.times do |color_nr|
      6.times do |symbol_nr|
        # for each color-symbol-combination there are two stones
        # when they are not on the board, their x,y is -1

        the_stone = {"symbol" => symbols[symbol_nr], "color" => colors[color_nr], "x" => -1, "y" => -1, "fit_count" => 0 }
        other_stones.push(the_stone)
        # pick the first_stones
        # (their randomness has been asserted by shuffling symbols & colors)
        if color_nr == symbol_nr
           first_stones.push(the_stone.dup)
        else
           other_stones.push(the_stone.dup)
        end
      end
    end
    other_stones.shuffle!
    self.stones = first_stones + other_stones
    self.current_stone_id = 0
  end

  def create_board
    # set up the board with 12x8 empty squares
    #   symbols \u2218 : small circle,  \u2219 : small bullet, \u2217 : 6-star
    self.board = (0..8*12).to_a
    8.times do |board_y|
      12.times do |board_x|
        self.clear_board(board_x, board_y)
      end
    end
  end

  # place the next stone in the stones list on the board
  def place_stone(board_x, board_y)
    if self.current_stone_id >= self.stones.length
      return  true  #there are no stones left to be palced
    end

    # after setting up the square with the first 6 stones
    # we have to check if the stone fits to his neighbours
    if self.current_stone_id >= 6
      fit_count = FitCounter.new(self).current_stone_fit_count(board_x, board_y)
      if fit_count < 1
        return true  # we are not allowed to place a stone there
      end
    else
      fit_count = 0
    end

    current_stone = self.stones[self.current_stone_id]
    current_stone["x"] = board_x
    current_stone["y"] = board_y
    current_stone["fit_count"] = fit_count
    self.score += calculate_score( fit_count )
    self.four_count += 1 if fit_count==4
    self.board[board_x + 12 * board_y] = current_stone
    self.current_stone_id += 1

    if self.save
      if self.score > 0
        ScoresController.helpers.insert_score self.score, self.user, self.name
      end
      return true
    end

    return false
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

    self.board[board_x + 12 * board_y] = {"symbol" => "\u25CC", "color" => 0, "x" => board_x, "y" => board_y, "fit_count" => 0 }
  end

  def undo_last_move
    if self.current_stone_id <= 6 # the stones 1-6 are not placed by the player
      return true
    end
    self.current_stone_id -= 1
    current_stone = self.stones[self.current_stone_id]
    take_stone_from_board(current_stone)

    # take back the score
    fit_count = current_stone["fit_count"]
    self.four_count -= 1 if fit_count==4
    self.score -= calculate_score(fit_count)
    self.score -= undo_penalty(self.undo_count)
    if self.score < 0
      self.score = 0
    end

    self.undo_count += 1
    return self.save
  end

  # style the board square depending on fitting neighbours
  def fit_indicator_class(board_x, board_y)
    fit_count = FitCounter.new(self).current_stone_fit_count(board_x, board_y)
    if fit_count == 0
      return ""
    end
    stone_class = "place-stone"
    if fit_count == 2
      stone_class += " two-fit"
    elsif fit_count == 3
      stone_class += " three-fit"
    elsif fit_count == 4
      stone_class += " four-way"
    end

    return stone_class
  end

  def take_stone_from_board(stone)
    board_x = stone["x"]
    board_y = stone["y"]
    self.clear_board(board_x, board_y)
    stone["x"] = -1
    stone["y"] = -1
  end

  # calculate score for stone placed with n fitting neighbours
  # the score depends on previous 4-ways, etc.
  def calculate_score(fit_count)
    bonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]
    score = 2 ** (fit_count + self.four_count - 1)
    score += bonus[self.four_count + 1] if fit_count == 4
    if self.current_stone_id == 71
      score += 1000
    elsif self.current_stone_id == 70
      score += 500
    elsif self.current_stone_id == 69
      score += 100
    end

    return score
  end

  # depending on previous undo_last_move
  # points are reduced after undo
  def undo_penalty(undo_count)
    return 2 ** undo_count
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
