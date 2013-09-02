require File.expand_path("../rsync/version", __FILE__)

# NOTE: Please don't depend on tasks without a description (`desc`) remaining
# as they are between minor or patch version releases. They make up the private
# API and internalas of Mina::Rsync. If you think something should be public
# for extending, please let me know!

set_default :repository, "."
set_default :branch, "master"
set_default :rsync_options, []
set_default :rsync_copy, "rsync --archive --acls --xattrs"

# Stage is used on your local machine for rsyncing from.
set_default :rsync_stage, "tmp/deploy"

# Cache is used on the server to copy files to from to the release directory.
# Saves you rsyncing your whole app folder each time.
set_default :rsync_cache, "shared/deploy"

run = lambda do |*cmd|
  if simulate_mode?
    puts "$ #{cmd.join(" ")}"
  else
    Kernel.system *cmd
  end
end

rsync_cache = lambda do
  cache = settings.rsync_cache
  raise TypeError, "Please set rsync_cache." unless cache
  cache = settings.deploy_to + "/" + cache if cache && cache !~ /^\//
  cache
end

desc "Stage and rsync to the server (or its cache)."
task :rsync => %w[rsync:stage] do
  puts "Rsyncing to #{rsync_cache.call}..."

  rsync = %w[rsync]
  rsync.concat settings.rsync_options
  rsync << settings.rsync_stage + "/"

  user = settings.user + "@" if settings.user
  host = settings.domain
  rsync << "#{user}#{host}:#{rsync_cache.call}"

  run.call *rsync
end

namespace :rsync do
  task :create_stage do
    next if File.directory?(settings.rsync_stage)
    puts "Cloning repository for the first time..."

    clone = %W[git clone]
    clone << settings.repository
    clone << settings.rsync_stage
    run.call *clone
  end

  desc "Stage the repository in a local directory."
  task :stage => %w[create_stage] do
    puts "Staging..."

    puts "$ cd #{settings.rsync_stage}" if simulate_mode?
    Dir.chdir settings.rsync_stage do
      run.call *%W[git fetch --quiet --all --prune]
      print "Git checkout: "
      run.call *%W[git reset --hard origin/#{settings.branch}]
    end
  end

  task :build do
    queue %(#{settings.rsync_copy} "#{rsync_cache.call}/" ".")
  end

  desc "Stage, rsync and copy to the build path."
  task :deploy => %w[rsync build]
end
