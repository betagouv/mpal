install: ## Install or update dependencies
	test -f config/database.yml || cp config/database.yml{.sample,}
	test -f .env || cp .env{.sample,}
	command -v bundler >/dev/null 2>&1 || gem install bundler --no-ri --no-rdoc
	bundle check || bundle install
	bundle exec rake db:migrate

run: ## Start the app server
	bin/rails server

test: ## Run the tests
	bin/rspec

clean: ## Clean temporary files and installed dependencies
	rm -rf ./tmp

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: install run test clean help
