# Seed the database of Review Apps
#
# A better way would be to have a postdeploy hook specifically for
# Review Apps, where we could execute `rake db:seed` cleanly.
# But such a hook doesn't exist on Scalingo yet (although it does
# on Heroku) ; hence this workaround.

if ENV['IS_REVIEW_APP'] == "true" && !ActiveRecord::Migrator.needs_migration?
  Rails.application.load_tasks
  Rake::Task['db:seed'].invoke
end
