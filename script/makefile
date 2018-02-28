# $@  target
# $<  first dependency 
# $^  all dependencies

all: node_modules ../public/address_app.html ../public/bundle.js address.db address_app.conf.json

node_modules:
	npm install

address_app.conf.json: address_app.conf.example
	cp $< $@
	@echo "* Don't forget to add your Google Map API key(s) to "$@

../public/address_app.html: xslate.pl address_app.html.tx address_app.conf.json
	mkdir -p ../public
	./xslate.pl > $@

../public/bundle.js: webpack.config.js address_app.conf.json src/index.js src/AddressMap.js src/AjaxAddress.js src/ListAddresses.js src/util.js
	npm run build

address.db:
	sqlite3 $@ < create.sql

clean:
	rm address.db
	rm ../public/address_app.html
	rm ../public/bundle.js

