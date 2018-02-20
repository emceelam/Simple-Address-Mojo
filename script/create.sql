/* SQLITE3 */
DROP TABLE IF EXISTS addresses;
CREATE TABLE IF NOT EXISTS addresses (
  id     INTEGER PRIMARY KEY ASC,
  street TEXT,
  city   TEXT,
  state  TEXT,
  zip    INTEGER,
  lat    REAL,  /* latitude */
  lng    REAL  /* longitude */
);

DELETE FROM addresses;

INSERT INTO addresses (street, city, state, zip)
  VALUES ("550 E Brokaw Rd", "San Jose", "CA", 95112);

INSERT INTO addresses (street, city, state, zip)
  VALUES ("1077 E Arques Ave", "Sunnyvale", "CA", 94085);
  

CREATE TABLE IF NOT EXISTS geocode (
  id     INTEGER PRIMARY KEY ASC,
  street TEXT,
  city   TEXT,
  state  TEXT,
  zip    INTEGER,
  lat    REAL,  /* latitude */
  lng    REAL  /* longitude */
);

DELETE FROM geocode;

INSERT INTO geocode (street, city, state, zip, lat, lng)
  VALUES ("550 E Brokaw Rd", "San Jose", "CA", 95112, 37.3798781, -121.9068);

INSERT INTO geocode (street, city, state, zip, lat, lng)
  VALUES ("1077 E Arques Ave", "Sunnyvale", "CA", 94085, 37.3824601, -122.001514);
