SELECT
  'create table ' || table_name || ' as select * from arruda.' || table_name || ';'
FROM
  all_tables
WHERE
    owner = 'ARRUDA'
    AND table_name LIKE 'AIR_%';
    

DROP TABLE AIR_AIRLINES;
DROP TABLE AIR_AIRPLANES;
DROP TABLE AIR_AIRPLANE_TYPES;

DROP TABLE AIR_FLIGHTS_SCHEDULES;
DROP TABLE AIR_PASSENGERS;
DROP TABLE AIR_PASSENGERS_DETAILS;

create table AIR_AIRLINES as select * from arruda.AIR_AIRLINES;
create table AIR_AIRPLANES as select * from arruda.AIR_AIRPLANES;
create table AIR_AIRPLANE_TYPES as select * from arruda.AIR_AIRPLANE_TYPES;
create table AIR_AIRPORTS as select * from arruda.AIR_AIRPORTS;
create table AIR_AIRPORTS_GEO as select * from arruda.AIR_AIRPORTS_GEO;
create table AIR_BOOKINGS as select * from arruda.AIR_BOOKINGS;
create table AIR_FLIGHTS as select * from arruda.AIR_FLIGHTS;
create table AIR_FLIGHTS_SCHEDULES as select * from arruda.AIR_FLIGHTS_SCHEDULES;
create table AIR_PASSENGERS as select * from arruda.AIR_PASSENGERS;
create table AIR_PASSENGERS_DETAILS as select * from arruda.AIR_PASSENGERS_DETAILS;



DROP TABLE "booking"."bookings_by_id";
DROP TABLE "booking"."passengers";
DROP TABLE "airport"."airports";
DROP TABLE "airport"."airlines";

CREATE KEYSPACE IF NOT EXISTS "booking" 
  WITH REPLICATION = {
    'class' : 'SimpleStrategy',
    'replication_factor' : 3
  }
AND DURABLE_WRITES = FALSE; 
 
USE "booking";
 
CREATE TABLE "booking"."bookings_by_id" (
  "flightno" text,
  "departure" timestamp,
  "booking_id" int,
  "last_name" text,
  "first_name" text,
  "seat" text,
  "passenger_id" int,
  PRIMARY KEY (("booking_id"),"passenger_id")
)
WITH CLUSTERING ORDER BY ("passenger_id" ASC);
 
CREATE TABLE "booking"."passengers_by_id" (
  "passenger_id" int,
  "booking_id" int,
  "last_name" text,
  "first_name" text,
  "birth_date" timestamp,
  "sex" text,
  "country" text,
  "city" text,
  "street" text,
  "zip" int,
  PRIMARY KEY (("passenger_id"),"first_name","booking_id")
)
WITH CLUSTERING ORDER BY ( "first_name" ASC, "booking_id" ASC);

CREATE KEYSPACE IF NOT EXISTS "airport" 
  WITH REPLICATION = {
    'class' : 'SimpleStrategy',
    'replication_factor' : 3
  }
AND DURABLE_WRITES = FALSE; 
 
USE "airport";
 
CREATE TABLE "airport"."airlines_by_id" (
  "airport_name" text,
  "airline_name" text,
  "iata" text,
  "airport_id" int,
  "airline_id" int,
  "airplane_id" int,
  "type_name" text,
  "capacity" int,
  PRIMARY KEY (( "airline_id"),"airport_id", "airplane_id", "capacity", "type_name")
)
WITH CLUSTERING ORDER BY ("airport_id" ASC,"airplane_id" ASC, "capacity" ASC, "type_name" ASC);

CREATE TABLE "airport"."airports_by_id" (
  "airport_id" int,
  "iata" text,
  "icao" text,
  "airport_name" text,
  "geo_name" text,
  "city" text,
  "country" text,
  "latitude" double,
  "longitude" double,
  PRIMARY KEY (("airport_id"), "airport_name", "city", "country")
)
WITH CLUSTERING ORDER BY ("airport_name" ASC, "city" ASC, "country" ASC);
 
 --Funciona
SELECT DISTINCT
    'insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values(' ||
    '''' || port.name || ''',' ||
    '''' || li.airline_name || ''',' ||
    '''' || li.iata || ''',' ||
     port.airport_id || ',' ||
     li.airline_id || ',' ||
     pla.airplane_id || ',' ||
     '''' || ty.name  || ''',' ||
     pla.capacity  || ');'
FROM
    air_airlines li
    inner join  air_airports port ON port.airport_id = li.base_airport_id
    inner join air_airplanes pla ON pla.airline_id = li.airline_id
    inner join air_airplane_types ty ON ty.airplane_type_id = pla.airplane_type_id
Where
    port.airport_id = 28 OR
    port.airport_id = 29 OR
    port.airport_id = 73 OR
    port.airport_id = 93 OR
    port.airport_id = 103
;

SELECT DISTINCT
    'insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(' ||
    port.airport_id || ',' ||
    '''' || port.iata || ''',' ||
    '''' || port.icao || ''',' ||
    '''' || port.name || ''',' ||
    '''' || geo.name || ''',' ||
    '''' || geo.city || ''',' ||
    '''' || geo.country || ''',' ||
     REPLACE(geo.latitude, ',', '.') || ',' ||
     REPLACE(geo.longitude, ',', '.') || ');'
FROM
    air_airports port
    inner join air_airports_geo geo ON geo.airport_id = port.airport_id
Where
    port.airport_id = 28 OR
    port.airport_id = 29 OR
    port.airport_id = 73 OR
    port.airport_id = 93 OR
    port.airport_id = 103
;





SELECT DISTINCT
    'insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values(' ||
    '''' || TRIM(fs.flightno) || ''',' ||
    '''' || TO_CHAR(f.departure,'yyyy-mm-dd hh24:mi:ss') || ''',' ||
    b.booking_id || ',' ||
    '''' || pas.lastname || ''',' ||
    '''' || pas.firstname || ''',' ||
    '''' || TRIM(b.seat) || ''',' ||
    pas.passenger_id || ');'
FROM
    air_flights_schedules fs
    inner join air_flights f ON f.flightno = fs.flightno
    inner join air_bookings b ON b.flight_id = f.flight_id
    inner join air_passengers pas ON pas.passenger_id = b.passenger_id
WHERE
    pas.passenger_id = 9999 OR
    pas.passenger_id = 23607 OR
    pas.passenger_id = 2524 OR
    pas.passenger_id = 8320 OR
    pas.passenger_id = 4876
;

SELECT DISTINCT
    'insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(' ||
    pas.passenger_id || ',' ||
    b.booking_id || ',' ||
    '''' || pas.lastname || ''',' ||
    '''' || pas.firstname || ''',' ||
    '''' || TO_CHAR(det.birthdate,'yyyy-mm-dd hh24:mi:ss') || ''',' ||
    '''' || det.sex || ''',' ||
    '''' || det.country || ''',' ||
    '''' || det.city || ''',' ||
    '''' || det.street || ''',' ||
     det.zip || ');'
FROM   
    air_passengers pas
    inner join air_passengers_DETAILS det ON det.passenger_id = pas.passenger_id
    inner join air_bookings b ON b.passenger_id = pas.passenger_id
WHERE
    pas.passenger_id = 9999 OR
    pas.passenger_id = 23607 OR
    pas.passenger_id = 2524 OR
    pas.passenger_id = 8320 OR
    pas.passenger_id = 4876
;


--Q1 -> Q2
--Q1 - Encontrar um passageiro pelo id e ordenar pelo booking
--Q2 - Buscar o detalhes boking

SELECT * FROM "booking"."bookings_by_id"
WHERE "booking_id" = 107923 ;


SELECT * FROM "booking"."passengers_by_id"
WHERE "passenger_id" = 9999;






insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,4894768,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(23607,35584371,'V','Michael Cronin,','1955-05-18 21:58:38','m','MOZAMBIQUE','Lavamünd','Rettenschöss 66',9472);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(9999,107923,'Quinn','Anthony Tyler','1966-02-18 21:58:38','w','UNITED STATES','Steinegg','Vordere Gasse 11',3591);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(23607,107959,'V','Michael Cronin,','1955-05-18 21:58:38','m','MOZAMBIQUE','Lavamünd','Rettenschöss 66',9472);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(9999,2585925,'Quinn','Anthony Tyler','1966-02-18 21:58:38','w','UNITED STATES','Steinegg','Vordere Gasse 11',3591);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,10819150,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(9999,16969547,'Quinn','Anthony Tyler','1966-02-18 21:58:38','w','UNITED STATES','Steinegg','Vordere Gasse 11',3591);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,24547158,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,10273170,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,20493313,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,28530155,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(8320,97014,'VIII','Dean Jones,','2005-04-18 21:58:38','m','FRANCE','Lauen','Hammerschafferweg 30',9722);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,97022,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,107932,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,670274,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,6705777,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(8320,11032707,'VIII','Dean Jones,','2005-04-18 21:58:38','m','FRANCE','Lauen','Hammerschafferweg 30',9722);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(23607,11105905,'V','Michael Cronin,','1955-05-18 21:58:38','m','MOZAMBIQUE','Lavamünd','Rettenschöss 66',9472);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(23607,19156898,'V','Michael Cronin,','1955-05-18 21:58:38','m','MOZAMBIQUE','Lavamünd','Rettenschöss 66',9472);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(4876,31378206,'Baker','Kathy','1973-08-18 21:58:38','m','CANADA','Gaming','Roischenauweg 62',3292);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,36960585,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(2524,426289,'Thomas','B. J.','1961-03-18 21:58:38','m','BRAZIL','Sankt Florian am Inn','Dorf 57',4782);
insert into booking.passengers_by_id(passenger_id,booking_id,last_name,first_name,birth_date,sex,country,city,street,zip) values(9999,25139099,'Quinn','Anthony Tyler','1966-02-18 21:58:38','w','UNITED STATES','Steinegg','Vordere Gasse 11',3591);

insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('LI8618','2023-06-20 13:07:30',31378206,'Baker','Kathy','3H',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SP2033','2021-11-12 04:51:51',107959,'V','Michael Cronin,','4G',23607);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('IT5184','2020-06-14 14:12:20',11032707,'VIII','Dean Jones,','62B',8320);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('MI3154','2021-11-11 09:56:55',20493313,'Thomas','B. J.','10A',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('ET1474','2021-08-09 04:26:40',670274,'Baker','Kathy','3B',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('AN5319','2021-05-18 01:27:23',10273170,'Thomas','B. J.','13C',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('TH8528','2021-10-15 12:47:20',25139099,'Quinn','Anthony Tyler','26G',9999);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SP2033','2021-11-12 04:51:51',107932,'Thomas','B. J.','14A',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SU7878','2020-12-10 06:05:38',19156898,'V','Michael Cronin,','15G',23607);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SP6456','2022-12-20 17:14:35',97022,'Baker','Kathy','15D',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('AF4264','2023-04-16 22:13:12',24547158,'Baker','Kathy','61A',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('IT8341','2022-06-25 10:48:14',11105905,'V','Michael Cronin,','48G',23607);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('IN3739','2023-08-06 18:20:03',6705777,'Baker','Kathy','49D',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('TA9362','2021-12-14 23:27:24',36960585,'Thomas','B. J.','28G',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('ET3573','2022-10-14 23:57:09',426289,'Thomas','B. J.','17C',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('TU5175','2023-01-26 10:19:49',35584371,'V','Michael Cronin,','80D',23607);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('GA9779','2021-05-21 15:23:16',28530155,'Thomas','B. J.','52E',2524);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('UN4962','2021-05-17 04:45:46',4894768,'Baker','Kathy','60A',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('RU2599','2020-09-25 01:00:24',2585925,'Quinn','Anthony Tyler','4G',9999);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SP6456','2022-12-20 17:14:35',97014,'VIII','Dean Jones,','18C',8320);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('NA7293','2021-01-22 04:45:40',16969547,'Quinn','Anthony Tyler','52A',9999);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('IT1211','2020-12-18 15:08:29',10819150,'Baker','Kathy','36C',4876);
insert into booking.bookings_by_id(flightno,departure,booking_id,last_name,first_name,seat,passenger_id) values('SP2033','2021-11-12 04:51:51',107923,'Quinn','Anthony Tyler','16F',9999);
------------
--Q3 -> Q4
--Q3 - Econtrar a airline pelo id
--Q4 - Buscar os dados do airport

SELECT * FROM "airport"."airlines_by_id"
WHERE "airline_id" = 19;

SELECT * FROM "airport"."airports_by_id"
WHERE "airport_id" = 28;



insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(28,'SNU','MUSC','ABEL SANTA MARIA','ABEL SANTA MARIA','SANTA CLARA','CUBA',22.493056,-79.938889);
insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(93,'QNV','SDNY','AEROCLUB','AEROCLUB','NOVA IGUACU','BRAZIL',-22.746667,-43.464722);
insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(103,'IXA','VEAT','AGARTALA','AGARTALA','AGARTALA','INDIA',23.89,91.242222);
insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(29,'OGO','DIAU','ABENGOUROU','ABENGOUROU','ABENGOUROU','IVORY COAST',6.716667,-3.466667);
insert into airport.airports_by_id(airport_id, iata, icao,  airport_name, geo_name, city, country, latitude, longitude ) values(73,'ADL','YPAD','ADELAIDE INTL','ADELAIDE INTL','ADELAIDE','AUSTRALIA',-34.945,138.530556);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,387,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,390,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,395,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,396,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,407,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,408,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,420,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,425,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,426,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,434,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,436,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,437,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,439,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,440,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,441,'Fokker 70',79);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,446,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,449,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,453,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,458,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,463,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,466,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,472,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,487,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,492,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,494,'Boeing 737',114);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,541,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,550,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,554,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,555,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,556,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,564,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,572,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,588,'Airbus-A320-Familie',150);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,609,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,610,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,615,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,621,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,625,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,629,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,637,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,646,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,647,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,659,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,665,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,677,'Douglas DC-9',115);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,699,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,704,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,712,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,717,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,727,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,733,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,739,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,742,'Fokker 100',95);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,378,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,403,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,419,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,429,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,442,'Douglas DC-9',115);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,443,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,456,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,460,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,461,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,470,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,476,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,490,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,496,'Bombardier Q Series',78);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,545,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,546,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,561,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,562,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,565,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,567,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,574,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,577,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,590,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,592,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,599,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,603,'Douglas DC-9',115);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,614,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,634,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,636,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,643,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,654,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,656,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,657,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,664,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,669,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,672,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,679,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,684,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,687,'Boeing 767',200);

insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,719,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,720,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,728,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,734,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,737,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,740,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,744,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,761,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,765,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,766,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,771,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,381,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,385,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,386,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,397,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,402,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,405,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,414,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,422,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,431,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,433,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,447,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,452,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,471,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,473,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,478,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,497,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,543,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,557,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,566,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,570,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,594,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,596,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,605,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,606,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,624,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,627,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,630,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,642,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,644,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,660,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,673,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,675,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,676,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,682,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,685,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,694,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,695,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,697,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,700,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,706,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,716,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,721,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,722,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,735,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,743,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,754,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,755,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,757,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,760,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,762,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,770,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,370,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,376,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,379,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,384,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,388,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,392,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,412,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,416,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,430,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,432,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,435,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,444,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,454,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,459,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,462,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,467,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,469,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,483,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,540,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,552,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,559,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,575,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,578,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,579,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,585,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,591,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,593,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,597,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,608,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,613,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,623,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,641,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,649,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,651,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,655,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,663,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,668,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,671,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,686,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,689,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,691,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,707,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,709,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,710,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,723,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,369,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,374,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,375,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,382,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,400,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,401,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,415,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,418,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,468,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,474,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,475,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,480,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,484,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,547,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,551,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,571,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,576,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,598,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,600,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,645,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,648,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,653,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,658,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,661,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,667,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,678,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,681,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,705,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,708,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,713,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,718,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,730,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,731,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,746,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,748,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,756,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,759,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,763,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,769,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,772,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,371,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,380,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,391,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,404,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,409,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,410,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,417,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,428,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,445,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,464,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,485,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,493,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,495,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,544,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,568,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,569,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,580,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,582,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,604,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,612,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,617,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,620,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,622,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,633,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,635,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,640,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,650,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,666,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,688,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,690,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,696,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,702,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,725,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,736,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,741,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,747,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,750,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,752,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,753,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,758,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,372,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,377,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,393,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,413,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,421,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,424,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,427,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,448,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,450,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,451,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,455,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,477,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,482,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,488,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,489,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,542,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,548,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,549,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,558,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,563,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,573,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,581,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,583,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,586,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,601,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,616,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,618,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,626,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,628,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,632,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,639,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,652,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,662,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,674,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,683,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,701,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,711,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,714,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,715,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,729,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,749,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,767,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,389,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,394,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,398,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,399,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,406,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,411,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,423,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,438,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,457,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,465,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,479,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,481,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,486,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABENGOUROU','Ivory Coast Airlines','IV',29,50,491,'Douglas DC-9',115);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,539,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,553,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,560,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,584,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,587,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,589,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,595,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ADELAIDE INTL','Australia Airlines','AU',73,6,602,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,607,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,611,'Airbus-A320-Familie',150);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,619,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,631,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,638,'Boeing 737',114);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,670,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AEROCLUB','Brazil Airlines','BR',93,12,680,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,692,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,693,'Boeing 747',335);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,698,'Airbus A380',644);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,703,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,724,'Fokker 70',79);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,726,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,732,'Boeing 767',200);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,738,'Boeing 777',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,745,'Bombardier Q Series',78);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,751,'Airbus A330',420);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,764,'Embraer-ERJ-145-Familie',50);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('AGARTALA','India Airlines','IN',103,46,768,'McDonnell Douglas DC-10',380);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,373,'Fokker 100',95);
insert into airport.airlines_by_id(airport_name, airline_name, iata, airport_id, airline_id, airplane_id, type_name, capacity ) values('ABEL SANTA MARIA','Cuba Airlines','CU',28,19,383,'Embraer-ERJ-145-Familie',50);