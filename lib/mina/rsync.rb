require File.expand_path("../rsync/version", __FILE__)

set_default :rsync_options, []
set_default :rsync_copy, "rsync --archive --acls --xattrs"
# Stage is used on your local machine for rsyncing from.
set_default :rsync_stage, "tmp/deploy"
# Cache is used on the server to copy files to from to the release directory.
# Saves you rsyncing your whole app folder each time.
set_default :rsync_cache, "tmp/deploy"

run = lambda do |*cmd|
  if simulate_mode?
    puts "$ #{cmd.join(" ")}"
  else
    Kernel.system *cmd
  end
end

rsync_path = lambda do
  path = settings.deploy_to
  path += "/" + settings.rsync_cache if settings.rsync_cache
  path
end

desc "Stage and rsync to the server."
task :rsync => %w[rsync:stage] do
  puts "Rsyncing..."

  rsync = %w[rsync]
  rsync.concat settings.rsync_options
  rsync << settings.rsync_stage + "/"

  user = settings.user + "@" if settings.user
  host = settings.domain
  rsync << "#{user}#{host}:#{rsync_path.call}"

  run.call *rsync
end

namespace :rsync do
  task :clone_stage do
    next if File.directory?(settings.rsync_stage)
    puts "Cloning repository for the first time..."

    clone = %W[git clone]
    clone << settings.repository
    clone << settings.rsync_stage
    run.call *clone
  end

  desc "Stage the repository in a local directory."
  task :stage => %w[clone_stage] do
    puts "Staging for rsyncing..."

    puts "$ cd #{settings.rsync_stage}" if simulate_mode?
    Dir.chdir settings.rsync_stage do
      run.call *%W[git fetch --quiet --all --prune]
      run.call *%W[git reset --hard origin/#{settings.branch}]
    end
  end

  desc "Copy the cache to the build path."
  task :build do
    queue %(#{settings.rsync_copy} "#{rsync_path.call}/" ".")
  end
end
