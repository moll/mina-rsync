# encoding: utf-8

require File.expand_path("../lib/mina/rsync/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "mina-rsync"
  gem.version = Mina::Rsync::VERSION
  gem.homepage = "https://github.com/moll/mina-rsync"
  gem.summary = <<-end.strip.gsub(/\s*\n\s*/, " ")
    Deploy with Rsync from any local (or remote) repository.
  end

  gem.description = <<-end.strip.gsub(/\s*?\n(\n?)\s*/, " \\1\\1")
    Deploy with Rsync to your server from any local (or remote) repository.

    Saves you the need to install Git on your production machine and deploy all
    of your development files each time!

    Suitable for deploying any apps, be it Ruby or Node.js.
  end

  gem.author = "Andri Möll"
  gem.email = "andri@dot.ee"
  gem.license = "LAGPL"

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(/^bin\//).map(&File.method(:basename))
  gem.test_files = gem.files.grep(/^spec\//)
  gem.require_paths = ["lib"]

  gem.add_dependency "mina", ">= 0.3.0", "< 2"
end
