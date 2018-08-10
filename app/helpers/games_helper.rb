module GamesHelper
  # style the board square depending on fitting neighbours
  def fit_indicator_class(fit_count)
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
end
