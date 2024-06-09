web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq --queue within_five_minutes -c 3
release: bundle exec rake db:migrate