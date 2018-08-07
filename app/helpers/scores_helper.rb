module ScoresHelper
  def score_table_len
    7
  end

  def low_scores
    Score.value_desc.offset( score_table_len )
  end

  def remove_lowest_scores
    # only keep the highest scores
    low_scores.destroy_all
  end

  def insert_score value, user, game_name
    # is the score high enough to enter the highscores?
    if Score.all.length >= score_table_len && Score.value_desc.last.value > value
      return
    end

    # is there yet a score from this game
    score = Score.find_by(user_id: user.id, game_name: game_name)
    if score && score.value < value
      score.value = value
      score.save
      return
    end

    score = Score.new(value: value, user_id: user.id, game_name: game_name)
    score.save
  end

  def get_rank game_name
    rank = Score.value_desc.pluck(:game_name).index(game_name)
    if !rank
      return ">" + score_table_len.to_s
    else
      return rank + 1
    end
  end
end
