class Seeder

private
  def ahead!(mark = '.')
    if (@progress += 1).multiple_of?(100)
      print mark unless '.' == mark
      puts @progress
    else
      print mark || '.'; STDOUT.flush
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
    puts unless @progress.multiple_of?(100)
    puts "--> #{@progress} item(s) processed"
  end

  def say(what)
    puts "-- #{what}"
  end

  def seeding(what)
    puts "== SEEDING #{what.to_s.upcase} ".ljust(70, '=')
  end
end

start = Time.now
seeds = Dir[File.expand_path('../seeds/*.rb', __FILE__)].sort
filter = (ENV['SEEDS'] || ENV['SEED']).to_s.downcase.split(',').reject(&:blank?).sort.uniq

seeder = Seeder.new
seeds.each do |seed|
  seed_name = File.basename(seed, '.rb').sub(/^\d+_/, '')
  next unless filter.blank? || filter.include?(seed_name)
  load seed
  unless seeder.respond_to?("seed_#{seed_name}")
    STDERR.puts "-- Skipping #{seed_name}: no matching method loaded into Seeder."
    next
  end
  seeder.send "seed_#{seed_name}"
  puts
end
puts "Finished seeding in #{Time.now - start} second(s)."

