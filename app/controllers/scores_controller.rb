class ScoresController < ApplicationController
  def index
    helpers.remove_lowest_scores
    @scores = Score.includes(:user).value_desc.all
  end
end
