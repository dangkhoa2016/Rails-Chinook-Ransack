namespace :db do
  desc 'Run db:seed with SQL logs enabled'
  task seed_with_sql_log: :environment do
    puts "Seed task started at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"

    # Enable SQL logging
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::DEBUG

    # Run the original db:seed task
    Rake::Task['db:seed'].invoke

    # Optionally
    # ActiveRecord::Base.logger = Rails.logger

    puts "Seed task completed at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end
end
