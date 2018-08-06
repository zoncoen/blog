setup:
	which hugo || brew install hugo
	make update

update:
	cd themes/hugo_theme_pickles
	git submodule update -i
