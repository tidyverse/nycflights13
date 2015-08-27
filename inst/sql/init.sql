# Load the airline delays data into MySQL

USE airlines;

DROP TABLE IF EXISTS flights;

create table flights (
  year smallint(4) NOT NULL default 0,
  month smallint(2) NOT NULL default 0,
  day smallint(2) NOT NULL default 0,
  dayOfWeek smallint(1) NOT NULL default 0,
  depTime smallint(4),
  CRSDepTime smallint(4) NOT NULL default 0,
  arrTime smallint(4),
  CRSArrTime smallint(4) NOT NULL default 0,
  carrier varchar(5) NOT NULL default '',
  flightNum smallint(6) NOT NULL default 0,
  tailNum varchar(8) NOT NULL default '',
  actualElapsedTime smallint(4) default NULL,
  CRSElapsedTime smallint(4) default NULL,
  airTime smallint(4) default NULL,
  arrDelay smallint(4) default NULL,
  depDelay smallint(4) default NULL,
  origin varchar(3) NOT NULL default '',
  dest varchar(3) NOT NULL default '',
  distance smallint(4) NOT NULL default 0,
  taxiIn smallint(4) default NULL,
  taxiOut smallint(4) default NULL,
  cancelled tinyint(1) NOT NULL default 0,
  cancellationCode varchar(1) NOT NULL default '',
  diverted varchar(1) NOT NULL default '',
  carrierDelay smallint(4) default NULL,
  weatherDelay smallint(4) default NULL,
  NASDelay smallint(4) default NULL,
  securityDelay smallint(4) default NULL,
  lateAircraftDelay smallint(4) default NULL,
  KEY `Year` (`Year`),
  KEY `Date` (`Year`, `Month`, `DayofMonth`),
  KEY `Origin` (`Origin`),
  KEY `Dest` (`Dest`),
  KEY `Carrier` (`carrier`)
  KEY `tailNum` (`tailNum`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
  PARTITION BY LIST (Year) (
    PARTITION p1 VALUES IN (1987),
    PARTITION p2 VALUES IN (1988),
    PARTITION p3 VALUES IN (1989),
    PARTITION p4 VALUES IN (1990),
    PARTITION p5 VALUES IN (1991),
    PARTITION p6 VALUES IN (1992),
    PARTITION p7 VALUES IN (1993),
    PARTITION p8 VALUES IN (1994),
    PARTITION p9 VALUES IN (1995),
    PARTITION p10 VALUES IN (1996),
    PARTITION p11 VALUES IN (1997),
    PARTITION p12 VALUES IN (1998),
    PARTITION p13 VALUES IN (1999),
    PARTITION p14 VALUES IN (2000),
    PARTITION p15 VALUES IN (2001),
    PARTITION p16 VALUES IN (2002),
    PARTITION p17 VALUES IN (2003),
    PARTITION p18 VALUES IN (2004),
    PARTITION p19 VALUES IN (2005),
    PARTITION p20 VALUES IN (2006),
    PARTITION p21 VALUES IN (2007),
    PARTITION p22 VALUES IN (2008),
    PARTITION p23 VALUES IN (2009),
    PARTITION p24 VALUES IN (2010),
    PARTITION p25 VALUES IN (2011),
    PARTITION p26 VALUES IN (2012),
    PARTITION p27 VALUES IN (2013),
    PARTITION p28 VALUES IN (2014),
    PARTITION p28 VALUES IN (2014)
);

DROP VIEW IF EXISTS summary;
CREATE VIEW summary AS
SELECT year, sum(1) as numFlights FROM ontime GROUP BY year;

