COMPONENT = ./node_modules/.bin/component
KARMA = ./node_modules/karma/bin/karma
JSHINT = ./node_modules/.bin/jshint
MOCHA = ./node_modules/.bin/mocha-phantomjs
BUMP = ./node_modules/.bin/bump
MINIFY = ./node_modules/.bin/minify
BFC = ./node_modules/.bin/bfc

build: components $(find lib/*.js)
	@${COMPONENT} build --dev

components: node_modules component.json
	@${COMPONENT} install --dev

clean:
	rm -fr build components dist

node_modules:
	npm install

minify: build
	${MINIFY} build/build.js build/build.min.js

standalone: node_modules
	@${COMPONENT} build --standalone ripple --name standalone
	-rm -r dist
	mkdir dist
	cp build/standalone.js dist/ripple.js && rm build/standalone.js
	@${MINIFY} dist/ripple.js dist/ripple.min.js
	bfc ./dist/ripple.js > ./dist/tmp.js && mv ./dist/tmp.js ./dist/ripple.js

karma: build
	${KARMA} start --no-auto-watch --single-run

lint: node_modules
	${JSHINT} lib/*.js

test: lint build
	${MOCHA} /test/runner.html

ci: test

patch:
	${BUMP} patch

minor:
	${BUMP} minor

release: test standalone
	VERSION=`node -p "require('./component.json').version"` && \
	git changelog --tag $$VERSION && \
	git release $$VERSION
	npm publish

.PHONY: clean test karma patch release standalone
