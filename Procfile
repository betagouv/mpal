web: bundle exec rails server -p $PORT -b 0.0.0.0
worker: bundle exec sidekiq -q default -q mailers
release:    bin/rake db:migrate db:seed_review_app after_party:run
postdeploy: bin/rake db:migrate db:seed_review_app after_party:run
