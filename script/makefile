# $@  target
# $<  first dependency 
# $^  all dependencies

all: address_app.html address.db address_app.conf

address_app.html: xslate.pl address_app.html.tx
	./xslate.pl > $@
	mkdir -p ../public
	cp address_app.html ../public/$@

address.db:
	sqlite3 $@ < create.sql

address_app.conf: address_app.conf.example
	cp $< $@
	@echo "* Don't forget to add your Google Map API key to "$@

clean:
	rm address.db
	rm address_app.html
	rm ../public/address_app.html

