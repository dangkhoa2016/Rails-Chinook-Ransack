namespace :db do
  desc "Run db:seed with SQL logs enabled"
  task seed_with_sql_log: :environment do
    # Enable SQL logging
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::DEBUG

    # Run the original db:seed task
    Rake::Task['db:seed'].invoke

    # Optionally, you can reset the logger after running the seed task
    ActiveRecord::Base.logger = Rails.logger
  end
end
