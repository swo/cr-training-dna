# User-set filenames
my_css = my.css
slides_html = index.html
slides_md = slides.md
slides_pdf = slides.pdf
filters := $(wildcard filters/*.lua)
chrome = /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome

# Derived parameters
filter_terms = $(foreach x,$(filters),--lua-filter=$(x))

.PHONY: html nofilter watch lwatch pdf

html: $(slides_html)

$(slides_html): $(slides_md) $(my_css) $(filters)
	pandoc -t revealjs -s $(filter_terms) -o $(slides_html) --css=$(my_css) -V revealjs-url=https://revealjs.com $(slides_md)

nofilter: $(slides_md) $(my_css)
	# Pandoc without the filter
	pandoc -t revealjs -s -o $(slides_html) --css=$(my_css) -V revealjs-url=https://revealjs.com $(slides_md)

watch:
	@echo Silently watching
	ls $(slides_md) $(my_css) | entr -n make html

lwatch:
	@echo Watching "loudly"
	ls $(slides_md) $(my_css) | entr make html

pdf: $(slides_pdf)

$(slides_pdf): $(slides_html)
	@echo Saving pdf using headless Chrome instance
	$(chrome) --headless --print-to-pdf='$(slides_pdf)' 'file://$(shell pwd)/$(slides_html)?print-pdf'
