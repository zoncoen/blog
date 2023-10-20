SHELL := env PATH='$(PATH)' bash

.PHONY: setup
setup:
	which hugo || brew install hugo
	make update

.PHONY: update
update:
	cd themes/hugo_theme_pickles
	git submodule update -i

.PHONY: lint
lint:
	@for p in $$(ls ./content/posts); do \
		f="./static/ogp/$$(basename $${p} .md).png"; \
		if [ ! -f "$$f" ]; then \
			echo "$$f does not exist."; \
			exit 1; \
		fi \
	done

.PHONY: tools
tools:
	go install github.com/zoncoen/tcardgen@v0.1.0
	npm install -g budoux@0.5.2

.PHONY: ogp
ogp:
	@git diff --name-only HEAD ./content/posts | xargs -I{} tcardgen -c ./tcardgen.yaml -f ./static/font -o ./static/ogp {}

.PHONY: ogp/all
ogp/all:
	@ls content/posts | xargs -I{} tcardgen -c ./tcardgen.yaml -f ./static/font -o ./static/ogp ./content/posts/{}
