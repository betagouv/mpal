web: bundle exec rails server -p $PORT -b 0.0.0.0
worker: bundle exec sidekiq -q default -q mailers
release:    bin/rails db:migrate            db:seed_review_app after_party:run
postdeploy: bin/rails db:migrate_review_app db:seed_review_app after_party:run
