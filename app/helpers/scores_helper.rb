module ScoresHelper
  def score_table_len
    50
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
      return "score outside"
    end

    # is there yet a score from this game
    score = Score.find_by(game_name: game_name)
    if score
      score.value = value if score.value < value
      score.user_id = user.id
      if score.save
        return "score found and saved"
      else
        return "score found, not saved"
      end
    end

    score = Score.new(value: value, user_id: user.id, game_name: game_name)
    if score.save
      return "score not found, new saved"
    else
      return "score not found, new not saved"
    end
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
