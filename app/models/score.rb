class Score < ApplicationRecord
  belongs_to :user

  scope :value_desc, -> { order(value: :desc) }
end
