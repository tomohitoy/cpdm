# capistranoの出力がカラーになる
require 'capistrano_colors'

# cap deploy時に自動で bundle install が実行される
require "bundler/capistrano"

# リポジトリの設定
set :application, "cpdm"
set :deploy_to, "/var/rails/cpdm"
set :user, "rails"
set :use_sudo, false

set :local_repository, "mysitegit:cpdm.git"
set :repository, "/var/git/cpdm.git"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache

set :normalize_asset_timestamps, false
set :keep_releases, 3

role :web, "mysitedeploy"
role :app, "mysitedeploy"
role :db,  "mysitedeploy", :primary => true

after "deploy:update", :roles => :app do
  run "cp #{shared_path}/config/database.yml #{release_path}/config/"
end

after "deploy:update", "deploy:cleanup"
after "deploy", "assets:precompile"

namespace :deploy do
  desc "Restarts your application."
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  desc "Load the seed data from db/seeds.rb"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
  desc "Reset the sql data"
  task :migratereset do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake db:migrate:reset"
  end
  desc "Start application"
  task :start do
    run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec unicorn_rails -c config/unicorn.rb -E #{rails_env} -D"
  end
  desc "Stop application"
  task :stop, :roles => :app do
    run "kill -s QUIT `cat /tmp/unicorn_#{application}.pid`"
  end
end

namespace :assets do
  task :precompile, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake assets:precompile"
  end
  task :cleanup, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production bundle exec rake assets:clean"
  end
end