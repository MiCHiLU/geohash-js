.SUFFIXES: .coffee .js
.coffee.js:
	coffee -b -c $<
.SUFFIXES: .js .min.js
.js.min.js:
	uglifyjs -nc -o $@ $<
COFFEE = $(wildcard *.coffee)
JS = $(COFFEE:.coffee=.js)
MINJS = $(JS:.js=.min.js)

all: $(MINJS)
