class User
  include Mongoid::Document
  field :user_id, type: Integer
  field :balance, type: BigDecimal, default: 0.0
  field :infinite_balance, type: Boolean, default: false
  field :last_message_time, type: Time, default: -> { Time.now }

  index({ user_id: 1 }, { unique: true, drop_dups: true })
end