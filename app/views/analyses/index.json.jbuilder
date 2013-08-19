json.array!(@analyses) do |analysis|
  json.extract! analysis, :content, :target
  json.url analysis_url(analysis, format: :json)
end
