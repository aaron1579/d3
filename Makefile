LOCALE ?= en_US

GENERATED_FILES = \
	d3.js \
	d3.min.js \
	component.json

all: $(GENERATED_FILES)

.PHONY: clean all test

test:
	@npm test

benchmark: all
	@node test/geo/benchmark.js

src/format/format-localized.js: src/locale.js src/format/format-locale.js
	LC_NUMERIC=$(LOCALE) locale -ck LC_NUMERIC | node src/locale.js src/format/format-locale.js > $@

src/time/format-localized.js: src/locale.js src/time/format-locale.js
	LC_TIME=$(LOCALE) locale -ck LC_TIME | node src/locale.js src/time/format-locale.js > $@

d3.js: $(shell node_modules/.bin/smash --list src/d3.js)
	@rm -f $@
	node_modules/.bin/smash src/d3.js \
		| sed 's/[[:<:]]VERSION[[:>:]]/"$(shell ./version)"/' \
		| node_modules/.bin/uglifyjs - -b indent-level=2 -o $@
	@chmod a-w $@

d3.min.js: d3.js
	@rm -f $@
	node_modules/.bin/uglifyjs $< -c -m -o $@

component.json: src/component.js d3.js
	@rm -f $@
	node src/component.js > $@
	@chmod a-w $@

clean:
	rm -f -- $(GENERATED_FILES)
