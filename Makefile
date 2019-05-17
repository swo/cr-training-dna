my_css = my.css
slides_html = index.html
slides_md = slides.md
filters := $(wildcard filters/*.lua)
filter_terms = $(foreach x,$(filters),--lua-filter=$(x))

html:
	pandoc -t revealjs -s $(filter_terms) -o $(slides_html) --css=$(my_css) -V revealjs-url=https://revealjs.com $(slides_md)

nofilter:
	# Pandoc without the filter
	pandoc -t revealjs -s -o $(slides_html) --css=$(my_css) -V revealjs-url=https://revealjs.com $(slides_md)

watch:
	@echo Silently watching
	ls $(slides_md) $(my_css) | entr -n make html

lwatch:
	@echo Watching "loudly"
	ls $(slides_md) $(my_css) | entr make html

pdf:
	@echo Put ?print-pdf at the end of the .html url in Chrome
