class Game
  class StonesManager
    def initialize(my_game)
      @game = my_game
    end

    def create
      # create the stones
      #symbols = ["a","b","c","x","y","z"].shuffle
      symbols = ["\u03C8","\u03B2","\u03B1","\u03B4","\u03BE","\u03C9"].shuffle # greek letters
      colors  = [1, 2, 3, 4, 5, 6].shuffle
      @game.stones = []
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
      @game.stones = first_stones + other_stones
      @game.current_stone_id = 0
    end

    def get_current_stone
      if @game.current_stone_id  > 71
        return nil
      end

      @game.stones[@game.current_stone_id]
    end

    def go_to_next_stone
      stone = self.get_current_stone
      @game.current_stone_id += 1
      stone
    end

    def back_to_previous_stone
      @game.current_stone_id -= 1
      current_stone = self.get_current_stone

      # take back the score
      fit_count = current_stone["fit_count"]
      @game.four_count -= 1 if fit_count==4
      @game.score -= self.calculate_score(fit_count)
      @game.score -= @game.undo_penalty
      if @game.score < 0
        @game.score = 0
      end

      @game.undo_count += 1
      current_stone
    end

    def before_first_move?
      @game.current_stone_id <= 6
    end

    def initial_stones_set?
      @game.current_stone_id >= 6
    end

    def all_stones_set?
      @game.current_stone_id >= @game.stones.length
    end

    # calculate score for stone placed with n fitting neighbours
    # the score depends on previous 4-ways, etc.
    def calculate_score(fit_count)
      bonus = [25, 50, 100, 200, 400, 600, 800, 1000, 5000, 10000, 25000, 50000]
      score = 2 ** (fit_count + @game.four_count - 1)
      score += bonus[@game.four_count + 1] if fit_count == 4
      if @game.current_stone_id == 71
        score += 1000
      elsif @game.current_stone_id == 70
        score += 500
      elsif @game.current_stone_id == 69
        score += 100
      end

      score
    end
  end
end
