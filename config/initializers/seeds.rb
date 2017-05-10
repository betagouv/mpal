# Seed the database of Review Apps
#
# A better way would be to have a postdeploy hook specifically for
# Review Apps, where we could execute `rake db:seed` cleanly.
# But such a hook doesn't exist on Scalingo yet (although it does
# on Heroku) ; hence this workaround.

module ReviewApp
  extend self

  def seed_if_needed
    # DEBUG
    [:review_app?, :rake_task?, :db_ready?, :db_needs_seeds?].each do |selector|
      begin
        puts "#{selector.to_s} " + send(selector).to_s
      rescue Exception => e
        puts "#{selector.to_s} <Exception>"
      end
    end

    if review_app? && !rake_task? && db_ready? && db_needs_seeds?
      Rails.application.load_seed
    end
  end

private

  def review_app?
    ENV['IS_REVIEW_APP'] == "true"
  end

  def rake_task?
    File.split($0).last == 'rake'
  end

  def db_ready?
    ActiveRecord::Migrator.needs_migration?
  rescue ActiveRecord::NoDatabaseError
    false
  end

  def db_needs_seeds?
    Intervenant.count == 0
  end
end

ReviewApp.seed_if_needed
