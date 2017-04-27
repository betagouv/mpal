require "rake"

shared_context "after_party" do
  let(:rake)      { Rake::Application.new }
  let(:file_name) { self.class.top_level_description }
  let(:file_path) { "lib/tasks/deployment/#{file_name}" }
  let(:task_name) { file_name.gsub(/^\d+_/, '') }
  subject         { rake["after_party:#{task_name}"] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == Rails.root.join("#{file_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(file_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)
    Rake.application.options.quiet = true

    Rake::Task.define_task(:environment)
  end
end
