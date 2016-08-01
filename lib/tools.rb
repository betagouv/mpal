module Tools
  def self.demo?
    ENV['DEMO'] == 'true'
  end
end
