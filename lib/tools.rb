module Tools
  def self.can_reset?
    ENV['RESET'] == 'true'
  end
end
