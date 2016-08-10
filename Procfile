web: bundle exec rails server -p $PORT -b 0.0.0.0 -e $RAILS_ENV
worker: bundle exec sidekiq -q default -q mailers -e $RAILS_ENV
