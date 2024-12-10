def random_time(from, to=Time.now)
  Time.at(from + rand * (to.to_f - from.to_f))
end

def seconds_a_day
  60 * 60 * 24
end

Album.find_each do |album|
  created_at = random_time(3.year.ago)
  updated_at = random_time(created_at, created_at.since(rand(10*seconds_a_day..100*seconds_a_day)))
  album.update_columns(created_at: created_at, updated_at: updated_at)
end
