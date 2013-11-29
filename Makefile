NAME = mina-rsync

love:
	@echo "Feel like makin' love."

pack:
	gem build $(NAME).gemspec

publish:
	gem push $(NAME)-*.gem

clean:
	rm -rf *.gem
	
.PHONY: love pack publish
.PHONY: clean
