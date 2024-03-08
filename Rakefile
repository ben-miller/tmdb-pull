require 'rake'

require_relative 'lib/tmdb_pull'

desc "Pull TMDB data to notes"
task :pull_to_notes do
  pull = Tmdb::PullToNotes.from_config
  pull.run
end

