# Seed the database of Review Apps
#
# A better way would be to have a postdeploy hook specifically for
# Review Apps, where we could execute `rake db:seed` cleanly.
# But such a hook doesn't exist on Scalingo yet (although it does
# on Heroku) ; hence this workaround.

namespace :db do
  desc "Seed the database of Review Apps"
  task seed_review_app: :environment do
    if ENV['IS_REVIEW_APP'] == "true" && Invitation.count == 0
      Rails.application.load_seed
    end
  end
end
