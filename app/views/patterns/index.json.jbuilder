json.array!(@patterns) do |pattern|
  json.extract! pattern, :user_id, :analysis_id, :title, :context, :consequence, :category, :example
  json.url pattern_url(pattern, format: :json)
end
$("#patterns").replaceWith('<div id="patterns"><%= escape_javascript(render @patterns)%></div>')
