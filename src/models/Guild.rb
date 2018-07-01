class Guild
  include Mongoid::Document
  field :guild_id, type: Integer
  field :log_channel_id, type: Integer, default: 0
  field :forbidden_words, type: Array, default: []
  field :role_auto, type: Integer, default: 0
  field :role_member, type: Integer, default: 0
  field :joinable_roles, type: Array, default: []

  index({ guild_id: 1 }, { unique: true, drop_dups: true })
end