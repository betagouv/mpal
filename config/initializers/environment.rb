# Ensure that the environment variables defined in .env.sample
# are present in the execution environment.
#
# This protects against out-to-date environment leading to runtime errors.

if ENV['RAILS_ENV'] != 'test'
  REFERENCE_ENV_FILE = File.join(Rails.root, '.env.sample')

  File.foreach(REFERENCE_ENV_FILE).with_index { |line, line_num|
    env_var = line[/([A-Z_]*)/, 1]
    if ENV[env_var].blank?
      raise "Configuration error: `#{env_var}` is not present in the process environment variables (declared in `.env.sample##{line_num}`)"
    end
  }
end
