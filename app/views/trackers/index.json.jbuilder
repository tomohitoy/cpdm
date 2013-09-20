json.array!(@trackers) do |tracker|
  json.extract! tracker, :user_id, :queue
  json.url tracker_url(tracker, format: :json)
end
