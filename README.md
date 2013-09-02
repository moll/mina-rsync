Mina::Rsync for Mina
====================
[![Gem version](https://badge.fury.io/rb/mina-rsync.png)](http://badge.fury.io/rb/mina-rsync)

**Deploy with Rsync** to your server from any local (or remote) repository when using [**Mina**](http://nadarei.co/mina).  
Saves you from having to install Git on your production machine and allows you to customize which files you want to deploy. Also allows you to easily precompile things on your local machine before deploying.

### Tour
- Suitable for deploying any apps, be it Ruby, Rails, Node.js or others.  
- Exclude files from being deployed with Rsync's `--exclude` options.
- Precompile files or assets easily before deploying, like JavaScript or CSS.
- Caches your previously deployed code to speed up deployments ~1337%.
- Currently works only with Git, so please shout out your interest in other SCMs.


Using
-----
Install with:
```
gem install mina-rsync
```

Require it at the top of your `Minafile` (or `config/deploy.rb`):
```ruby
require "mina/rsync"
```

Set some `rsync_options` to your liking:
```ruby
set :rsync_options, %w[--recursive --delete --delete-excluded --exclude .git*]
```

Then invoke Mina::Rsync's tasks from your `deploy` task:
```ruby
task :deploy do
  deploy do
    invoke "rsync:deploy"
  end
end
```

And after setting regular Mina options, deploy as usual!
```
mina deploy
```

### Implementation
1. Clones and updates your repository to `rsync_stage` (defaults to `tmp/deploy`) on your local machine.
2. Checks out the branch set in the `branch` variable (defaults to `master`).
3. Rsyncs to `rsync_cache` (defaults to `shared/deploy`) on the server.
4. Copies the content of the cache directory to the build directory.

After that, Mina takes over and runs its usual tasks and symlinking.

### Excluding files from being deployed
If you don't want to deploy everything you've committed to your repository, pass some `--exclude` options to Rsync:
```ruby
set :rsync_options, %w[
  --recursive --delete --delete-excluded
  --exclude .git*
  --exclude /config/database.yml
  --exclude /test/***
]
```

### Precompile assets before deploy
Mina::Rsync runs `rsync:stage` before rsyncing. Hook to that like this:
```ruby
task :precompile do
  Dir.chdir settings.rsync_stage do
    system "rake", "assets:precompile"
  end
end

task "rsync:stage" do
  invoke "precompile"
end
```


Configuration
-------------
Set Mina variables with `set name, value`.

Name          | Default | Description
--------------|---------|------------
repository    | `.` | The path or URL to a Git repository to clone from.  
branch        | `master` | The Git branch to checkout.  
rsync_stage   | `tmp/deploy` | Path where to clone your repository for staging, checkouting and rsyncing. Can be both relative or absolute.
rsync_cache   | `shared/deploy` | Path where to cache your repository on the server to avoid rsyncing from scratch each time. Can be both relative or absolute.
rsync_options | `[]` | Array of options to pass to `rsync`.  


License
-------
Mina::Rsync is released under a *Lesser GNU Affero General Public License*, which in summary means:

- You **can** use this program for **no cost**.
- You **can** use this program for **both personal and commercial reasons**.
- You **do not have to share your own program's code** which uses this program.
- You **have to share modifications** (e.g bug-fixes) you've made to this program.

For more convoluted language, see the `LICENSE` file.


About
-----
**[Andri Möll](http://themoll.com)** made this happen.  
[Monday Calendar](https://mondayapp.com) was the reason I needed this.

If you find Mina::Rsync needs improving, please don't hesitate to type to me now at [andri@dot.ee](mailto:andri@dot.ee) or [create an issue online](https://github.com/moll/mina-rsync/issues).
