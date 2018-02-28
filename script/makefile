# $@  target
# $<  first dependency 
# $^  all dependencies

all: ../public/address_app.html address.db address_app.conf

address_app.conf: address_app.conf.example
	cp $< $@
	@echo "* Don't forget to add your Google Map API key(s) to "$@

../public/address_app.html: xslate.pl address_app.html.tx address_app.conf
	mkdir -p ../public
	./xslate.pl > $@

address.db:
	sqlite3 $@ < create.sql

clean:
	rm address.db
	rm address_app.html
	rm ../public/address_app.html

