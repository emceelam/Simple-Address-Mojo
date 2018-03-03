# $@  target
# $<  first dependency 
# $^  all dependencies

all: script/address.db address_app.conf.json

address_app.conf.json: address_app.conf.example
	cp $< $@
	@echo "* Don't forget to add your Google Map API key(s) to "$@

script/address.db:
	sqlite3 $@ < script/create.sql
	chgrp webteam $@
	chmod g+w $@

clean:
	rm script/address.db

