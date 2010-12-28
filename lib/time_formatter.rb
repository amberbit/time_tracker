module TimeFormatter
  def self.format(time_in_seconds)
    time = split(time_in_seconds)
    "#{time[:hours]}h #{time[:minutes]}m #{time[:seconds]}s"
  end

  def self.short_format(time_in_seconds)
    time = split(time_in_seconds)
    time.each do |kind, amount|
      time[kind] = '%02d' % amount
    end
    "(#{time[:hours]}:#{time[:minutes]}:#{time[:seconds]})"
  end

  private

  def self.split(seconds)
    {
      hours: (seconds / 3600).floor,
      minutes: (seconds / 60 % 60).floor,
      seconds: (seconds % 60).floor
    }
  end
end
