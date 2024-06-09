web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq --queue within_five_minutes --queue default -c 3
release: bundle exec rake db:migrate