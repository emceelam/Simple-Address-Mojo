# $@  target
# $<  first dependency 
# $^  all dependencies

all: address_app.html address.db

address_app.html: xslate.pl address_app.html.tx
	./xslate.pl > $@
	cp address_app.html ../public/$@

address.db:
	sqlite3 $@ < create.sql

clean:
	rm address.db
	rm address_app.html
	rm ../public/address_app.html

