json.array!(@patterns) do |pattern|
  json.extract! pattern, :user_id, :title, :context, :analysis_id, :consequence, :category, :example
  json.url pattern_url(pattern, format: :json)
end
