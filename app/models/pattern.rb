class Pattern
  include Mongoid::Document
  field :user_id, type: Integer
  field :title, type: String
  field :context, type: String
  field :analysis_id, type: Integer
  field :consequence, type: String
  field :category, type: Integer
  field :example, type: String
end
