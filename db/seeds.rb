class Seeder
  def initialize(verbose: false)
    @verbose = verbose
  end

private
  def ahead!(mark = '.')
    if (@progress += 1).multiple_of?(100)
      log mark unless '.' == mark
      log_line @progress
    else
      log mark || '.'; STDOUT.flush
    end
  end

  def clear_table(*table_names)
    table_names.flatten.reject(&:blank?).each do |table_name|
      cnx.execute "TRUNCATE #{cnx.quote_table_name table_name} RESTART IDENTITY CASCADE"
    end
  end
  alias_method :clear_tables, :clear_table

  def cnx
    ActiveRecord::Base.connection
  end

  def progress(&block)
    @progress = 0
    block.call
    log_line unless @progress.multiple_of?(100)
    log_line "--> #{@progress} item(s) processed"
  end

  def say(what)
    log_line "-- #{what}"
  end

  def seeding(what)
    log_line "Seeding #{what.to_s} "
  end

  def log(message)
    if @verbose
      print message
    end
  end

  def log_line(message = "")
    if @verbose
      puts message
    end
  end
end

start = Time.now
seeds = Dir[File.expand_path('../seeds/*.rb', __FILE__)].sort
filter = (ENV['SEEDS'] || ENV['SEED']).to_s.downcase.split(',').reject(&:blank?).sort.uniq
verbose = (ENV['RAILS_ENV'] == 'development')

print "Seeding database… "

seeder = Seeder.new(verbose: verbose)
seeds.each do |seed|
  seed_name = File.basename(seed, '.rb').sub(/^\d+_/, '')
  next unless filter.blank? || filter.include?(seed_name)
  load seed
  unless seeder.respond_to?("seed_#{seed_name}")
    STDERR.puts "-- Skipping #{seed_name}: no matching method loaded into Seeder."
    next
  end
  puts if verbose
  seeder.send "seed_#{seed_name}"
end

if verbose
  puts
  puts "Finished seeding in #{Time.now - start} second(s)."
else
  puts "Done"
end
