# Migrate the database of Review Apps
#
# If database is empty, we prefer run a `schema:load` rather than
# all migrations.

namespace :db do
  desc "Migrate the database of Review Apps"
  task migrate_review_app: :environment do
    if ENV["IS_REVIEW_APP"] == "true" && ActiveRecord::Migrator.current_version <= 0
      sh %{rails db:schema:load}
    else
      sh %{rails db:migrate}
    end
  end
end

