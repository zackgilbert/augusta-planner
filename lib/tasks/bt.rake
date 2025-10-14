# Override the default bt:link task to create symlinks with the full gem name (including version)
# This ensures Tailwind can find the gems in tmp/gems/ with the pattern ./tmp/gems/*/

Rake::Task["bt:link"].clear if Rake::Task.task_defined?("bt:link")

namespace :bt do
  desc "Symlink registered gems in `./tmp/gems` so their views, etc. can be inspected by Tailwind CSS."
  task link: :environment do
    if Dir.exist?("tmp/gems")
      puts "Removing previously linked gems."
      FileUtils.rm_rf(Dir.glob("tmp/gems/*"))
    else
      if File.exist?("tmp/gems")
        raise "A file named `tmp/gems` already exists? It has to be removed before we can create the required directory."
      end

      puts "Creating 'tmp/gems' directory."
      FileUtils.mkdir_p("tmp/gems")
    end

    FileUtils.touch("tmp/gems/.keep")

    BulletTrain.linked_gems.each do |linked_gem|
      begin
        spec = Gem::Specification.find_by_name(linked_gem)
        target = spec.gem_dir
        gem_name = File.basename(target)
        link_path = File.join("tmp/gems", gem_name)
        puts "Linking '#{linked_gem}' to '#{link_path}'"
        FileUtils.ln_s(target, link_path, force: true)
      rescue Gem::MissingSpecError
        puts "Warning: Could not find gem '#{linked_gem}'"
      end
    end
    
    puts "\nSymlinks created in tmp/gems/:"
    Dir.glob("tmp/gems/bullet_train*").sort.each do |link|
      target = File.readlink(link).strip
      puts "  #{File.basename(link)}"
    end
  end
end
