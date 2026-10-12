--
-- PostgreSQL database dump
--

\restrict s7KST8yyhEDtAJnBfurSgMiAnhW61tUbdPUJPLjQ5O0n7EjnHY1MvEYql5123UT

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: average_review_point(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.average_review_point(p_tripid character) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_rating NUMERIC;
BEGIN
    SELECT AVG(R.rating)
    INTO avg_rating
    FROM "Review" R
    WHERE R."tripId" = p_tripId;

    RETURN avg_rating;
END;
$$;


ALTER FUNCTION public.average_review_point(p_tripid character) OWNER TO postgres;

--
-- Name: calculatetourguidetrip(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculatetourguidetrip(p_tourguideid character) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    trip_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO trip_count
    FROM "Trip"
    WHERE "tourGuideId" = p_tourguideid;

    RETURN trip_count;
END;
$$;


ALTER FUNCTION public.calculatetourguidetrip(p_tourguideid character) OWNER TO postgres;

--
-- Name: calculatetripduration(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculatetripduration(p_tripid character) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    sDate DATE;
    eDate DATE;
    tripDuration INTEGER;
BEGIN
    -- Trip tablosundan tarihleri al
    SELECT "startDate", "endDate"
    INTO sDate, eDate
    FROM "Trip"
    WHERE "tripId" = p_tripId;

    -- Tarihler varsa süreyi hesapla
    IF eDate >= sDate THEN
        tripDuration := eDate - sDate;
    ELSE
        tripDuration := 0;
    END IF;

    RETURN tripDuration;
END;
$$;


ALTER FUNCTION public.calculatetripduration(p_tripid character) OWNER TO postgres;

--
-- Name: checkGuideCompanyMatchTR(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."checkGuideCompanyMatchTR"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    guideCompanyId CHAR(5);
BEGIN
    SELECT "companyId" INTO guideCompanyId
    FROM "TourGuide"
    WHERE "personId" = NEW."tourGuideId";

    IF NEW."tourGuideId" IS NOT NULL THEN
        IF guideCompanyId <> NEW."companyId" THEN
            RAISE EXCEPTION 'Seçilen rehber bu turun bağlı olduğu şirkette çalışmıyor. Rehber ve Tur aynı şirkete ait olmalıdır.';     
            END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."checkGuideCompanyMatchTR"() OWNER TO postgres;

--
-- Name: check_review_traveler_trip(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_review_traveler_trip() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM "TravelerTrip"
        WHERE "personId" = NEW."travelerId"
          AND "tripId" = NEW."tripId"
    ) THEN
        RAISE EXCEPTION
        'This traveler did not join this trip and cannot write a review';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_review_traveler_trip() OWNER TO postgres;

--
-- Name: check_visit_date_between_trip_dates(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_visit_date_between_trip_dates() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    trip_start DATE;
    trip_end   DATE;
BEGIN
    -- Trip tarihlerini al
    SELECT "startDate", "endDate"
    INTO trip_start, trip_end
    FROM "Trip"
    WHERE "tripId" = NEW."tripId";

    -- Kontrol
    IF NEW."visitDate" < trip_start
       OR NEW."visitDate" > trip_end THEN
        RAISE EXCEPTION
        'visitDate (%), Trip tarihleri (%) - (%) arasında olmalıdır',
        NEW."visitDate", trip_start, trip_end;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_visit_date_between_trip_dates() OWNER TO postgres;

--
-- Name: countrytotalvisitcount(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.countrytotalvisitcount(p_country_id character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_count INT;
BEGIN
    SELECT COUNT(*)
    INTO total_count
    FROM "Trip"
    WHERE "countryId" = p_country_id;

    RETURN total_count;
END;
$$;


ALTER FUNCTION public.countrytotalvisitcount(p_country_id character varying) OWNER TO postgres;

--
-- Name: reviewcontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reviewcontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM "Review"
        WHERE "travelerId" = NEW."travelerId"
          AND "tripId" = NEW."tripId"
    ) THEN
        RAISE EXCEPTION 'This traveler already reviewed this trip' ;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.reviewcontrol() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Accommodation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Accommodation" (
    "accommodationId" character(1) CONSTRAINT "Accomadation_accomadationId_not_null" NOT NULL,
    name character varying CONSTRAINT "Accomadation_name_not_null" NOT NULL,
    address character varying CONSTRAINT "Accomadation_address_not_null" NOT NULL,
    country character varying CONSTRAINT "Accomadation_country_not_null" NOT NULL,
    "companyId" character(1) CONSTRAINT "Accomadation_companyId_not_null" NOT NULL
);


ALTER TABLE public."Accommodation" OWNER TO postgres;

--
-- Name: Company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Company" (
    "companyId" character(1) CONSTRAINT "Company_countryId_not_null" NOT NULL,
    "CompanyName" character varying CONSTRAINT "Company_name_not_null" NOT NULL
);


ALTER TABLE public."Company" OWNER TO postgres;

--
-- Name: Country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Country" (
    "countryId" character(1) NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public."Country" OWNER TO postgres;

--
-- Name: Person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Person" (
    "personId" character(1) NOT NULL,
    name character varying,
    email character(1) NOT NULL,
    "phoneNumber" character varying NOT NULL,
    "personType" character(1) NOT NULL
);


ALTER TABLE public."Person" OWNER TO postgres;

--
-- Name: Review; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Review" (
    "reviewId" character(5) NOT NULL,
    rating integer NOT NULL,
    comment character varying,
    "travelerId" character(1) CONSTRAINT "Review_personId_not_null" NOT NULL,
    "tripId" character(1) NOT NULL
);


ALTER TABLE public."Review" OWNER TO postgres;

--
-- Name: TourGuide; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TourGuide" (
    "personId" character(1) NOT NULL,
    "companyId" character(1) NOT NULL,
    "experienceYear" integer
);


ALTER TABLE public."TourGuide" OWNER TO postgres;

--
-- Name: TouristicPlace; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TouristicPlace" (
    "placeId" character(1) CONSTRAINT "TouristicPlaces_placeId_not_null" NOT NULL,
    name character varying CONSTRAINT "TouristicPlaces_name_not_null" NOT NULL,
    "countryId" character(1) CONSTRAINT "TouristicPlaces_countryId_not_null" NOT NULL
);


ALTER TABLE public."TouristicPlace" OWNER TO postgres;

--
-- Name: Traveler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Traveler" (
    "personId" character(10) NOT NULL,
    "passportNumber" character(10) NOT NULL
);


ALTER TABLE public."Traveler" OWNER TO postgres;

--
-- Name: TravelerTrip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TravelerTrip" (
    "personId" character(1) NOT NULL,
    "tripId" character(1) NOT NULL
);


ALTER TABLE public."TravelerTrip" OWNER TO postgres;

--
-- Name: Trip; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Trip" (
    "tripId" character(1) NOT NULL,
    "startDate" date CONSTRAINT "Trip_tripPeriod_not_null" NOT NULL,
    "tourGuideId" character(1) NOT NULL,
    "companyId" character(1) NOT NULL,
    "accommodationId" character(1),
    "countryId" character(1) CONSTRAINT "Trip_counrtyId_not_null" NOT NULL,
    "endDate" date CONSTRAINT "Trip_tripEndDate_not_null" NOT NULL
);


ALTER TABLE public."Trip" OWNER TO postgres;

--
-- Name: TripTouristicPlace; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TripTouristicPlace" (
    "tripId" character(1) NOT NULL,
    "placeId" character(1) NOT NULL,
    "visitDate" date NOT NULL
);


ALTER TABLE public."TripTouristicPlace" OWNER TO postgres;

--
-- Data for Name: Accommodation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Accommodation" VALUES
	('1', 'Museum Cave Hotel', 'Goreme, Nevsehir', '1', '1'),
	('2', 'Marmaris Blue Resort', 'Marmaris, Mugla', '2', '2'),
	('3', 'Colosseum Grand Hotel', 'City Center, Rome', '3', '3'),
	('4', 'Eiffel View Plaza', 'Champs-Elysees, Paris', '4', '4'),
	('5', 'Granada Palace Hotel', 'Alhambra St, Granada', '5', '5');


--
-- Data for Name: Company; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Company" VALUES
	('1', 'Cappadocia Balloon Tours'),
	('2', 'Aegean Blue Voyage'),
	('3', 'Rome Ancient Walks'),
	('4', 'Paris Romantic Travel'),
	('5', 'Andalusia Adventures');


--
-- Data for Name: Country; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Country" VALUES
	('1', 'Turkey'),
	('2', 'Italy'),
	('3', 'Japan'),
	('4', 'France'),
	('5', 'amreica');


--
-- Data for Name: Person; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Person" VALUES
	('1', 'Ahmet Yilmaz', 'A', '5551111', 'G'),
	('2', 'Ayse Demir', 'B', '5552222', 'G'),
	('3', 'Mehmet Oz', 'C', '5553333', 'G'),
	('4', 'Fatma Kaya', 'D', '5554444', 'G'),
	('5', 'Can Yildiz', 'E', '5555555', 'G'),
	('6', 'Ali Veli', 'F', '5556666', 'T'),
	('7', 'Zeynep Su', 'G', '5557777', 'T'),
	('8', 'Murat Boz ', 'H', '5558888', 'T'),
	('9', 'Selin Sen ', 'I', '5559999', 'T');


--
-- Data for Name: Review; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Review" VALUES
	('2    ', 4, 'The sea was beautiful, liked it.', '7', '2'),
	('3    ', 5, 'Historic atmosphere was great.', '8', '3'),
	('4    ', 3, 'Hotel was okay but food was cold.', '9', '4'),
	('1    ', 5, 'Absolutely amazing experience!', '6', '1'),
	('5    ', 3, 'It was fine', '5', '1');


--
-- Data for Name: TourGuide; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TourGuide" VALUES
	('1', '1', 3),
	('2', '2', 4),
	('3', '3', 8),
	('4', '4', NULL),
	('5', '1', 2),
	('6', '5', 1);


--
-- Data for Name: TouristicPlace; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TouristicPlace" VALUES
	('1', 'Goreme Open Air Museum', '1'),
	('2', 'Ephesus Ancient City', '2'),
	('3', 'The Colosseum', '3'),
	('4', 'The Eiffel Tower', '4'),
	('5', 'The Alhambra Palace', '5');


--
-- Data for Name: Traveler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Traveler" VALUES
	('6         ', 'K         '),
	('7         ', 'L         '),
	('8         ', 'M         '),
	('9         ', 'N         '),
	('5         ', 'A         '),
	('2         ', 'S532345   ');


--
-- Data for Name: TravelerTrip; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TravelerTrip" VALUES
	('6', '1'),
	('7', '2'),
	('8', '3'),
	('9', '4'),
	('5', '1');


--
-- Data for Name: Trip; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Trip" VALUES
	('1', '2025-06-01', '5', '1', '1', '1', '2025-06-15'),
	('2', '2025-07-15', '4', '2', '2', '2', '2025-07-25'),
	('3', '2025-08-20', '1', '3', '3', '3', '2025-08-25'),
	('4', '2025-09-10', '3', '4', '4', '4', '2025-09-17'),
	('5', '2025-10-05', '6', '5', '5', '5', '2025-10-15');


--
-- Data for Name: TripTouristicPlace; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."TripTouristicPlace" VALUES
	('1', '1', '2025-06-02'),
	('2', '2', '2025-07-16'),
	('3', '3', '2025-08-21'),
	('4', '4', '2025-09-11');


--
-- Name: TouristicPlace TouristicPlaces_countryId_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "TouristicPlaces_countryId_key" UNIQUE ("countryId");


--
-- Name: TouristicPlace TouristicPlaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "TouristicPlaces_pkey" PRIMARY KEY ("placeId");


--
-- Name: TravelerTrip TravelerTrip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TravelerTrip"
    ADD CONSTRAINT "TravelerTrip_pkey" PRIMARY KEY ("personId", "tripId");


--
-- Name: TripTouristicPlace TripTouristicPlace_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "TripTouristicPlace_pkey" PRIMARY KEY ("placeId", "tripId");


--
-- Name: Trip Trip_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "Trip_pkey" PRIMARY KEY ("tripId");


--
-- Name: Accommodation unique_Accomadation_accomadationId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Accommodation"
    ADD CONSTRAINT "unique_Accomadation_accomadationId" PRIMARY KEY ("accommodationId");


--
-- Name: Company unique_Company_countryId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Company"
    ADD CONSTRAINT "unique_Company_countryId" PRIMARY KEY ("companyId");


--
-- Name: Country unique_Country_countryId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Country"
    ADD CONSTRAINT "unique_Country_countryId" PRIMARY KEY ("countryId");


--
-- Name: Country unique_Country_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Country"
    ADD CONSTRAINT "unique_Country_name" UNIQUE (name);


--
-- Name: Person unique_Person_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "unique_Person_email" UNIQUE (email);


--
-- Name: Person unique_Person_personId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "unique_Person_personId" PRIMARY KEY ("personId");


--
-- Name: Review unique_Review_personId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "unique_Review_personId" UNIQUE ("travelerId");


--
-- Name: Review unique_Review_reviewId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "unique_Review_reviewId" PRIMARY KEY ("reviewId");


--
-- Name: Review unique_Review_travelerId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "unique_Review_travelerId" UNIQUE ("travelerId");


--
-- Name: TourGuide unique_TourGuide_personId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TourGuide"
    ADD CONSTRAINT "unique_TourGuide_personId" PRIMARY KEY ("personId");


--
-- Name: TouristicPlace unique_TouristicPlaces_countryId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "unique_TouristicPlaces_countryId" UNIQUE ("countryId");


--
-- Name: TouristicPlace unique_TouristicPlaces_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "unique_TouristicPlaces_name" UNIQUE (name);


--
-- Name: TouristicPlace unique_TouristicPlaces_placeId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "unique_TouristicPlaces_placeId" UNIQUE ("placeId");


--
-- Name: TravelerTrip unique_TravelerTrip_personId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TravelerTrip"
    ADD CONSTRAINT "unique_TravelerTrip_personId" UNIQUE ("personId");


--
-- Name: Traveler unique_Traveler_passportNumber; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Traveler"
    ADD CONSTRAINT "unique_Traveler_passportNumber" UNIQUE ("passportNumber");


--
-- Name: Traveler unique_Traveler_personId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Traveler"
    ADD CONSTRAINT "unique_Traveler_personId" PRIMARY KEY ("personId");


--
-- Name: TripTouristicPlace unique_TripTouristicPlace_placeId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "unique_TripTouristicPlace_placeId" UNIQUE ("placeId");


--
-- Name: TripTouristicPlace unique_TripTouristicPlace_tripId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "unique_TripTouristicPlace_tripId" UNIQUE ("tripId");


--
-- Name: TripTouristicPlace unique_TripTouristicPlace_visitDate; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "unique_TripTouristicPlace_visitDate" UNIQUE ("visitDate");


--
-- Name: Trip unique_Trip_tripId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "unique_Trip_tripId" UNIQUE ("tripId");


--
-- Name: index_countryId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_countryId" ON public."TouristicPlace" USING btree ("countryId");


--
-- Name: index_placeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_placeId" ON public."TripTouristicPlace" USING btree ("placeId");


--
-- Name: index_tripId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_tripId" ON public."TripTouristicPlace" USING btree ("tripId");


--
-- Name: Review reviewcontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER reviewcontrol BEFORE INSERT ON public."Review" FOR EACH ROW EXECUTE FUNCTION public.reviewcontrol();


--
-- Name: Review trg_check_review_traveler_trip; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_review_traveler_trip BEFORE INSERT ON public."Review" FOR EACH ROW EXECUTE FUNCTION public.check_review_traveler_trip();


--
-- Name: TripTouristicPlace trg_check_visit_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_visit_date BEFORE INSERT OR UPDATE ON public."TripTouristicPlace" FOR EACH ROW EXECUTE FUNCTION public.check_visit_date_between_trip_dates();


--
-- Name: Trip trg_checkguidecompanymatch; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_checkguidecompanymatch BEFORE INSERT OR UPDATE ON public."Trip" FOR EACH ROW EXECUTE FUNCTION public."checkGuideCompanyMatchTR"();


--
-- Name: Trip link_Accommodaiton_Trip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "link_Accommodaiton_Trip_1" FOREIGN KEY ("accommodationId") REFERENCES public."Accommodation"("accommodationId");


--
-- Name: Accommodation link_Company_Acommodation_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Accommodation"
    ADD CONSTRAINT "link_Company_Acommodation_1" FOREIGN KEY ("companyId") REFERENCES public."Company"("companyId");


--
-- Name: TourGuide link_Company_TourGuide_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TourGuide"
    ADD CONSTRAINT "link_Company_TourGuide_1" FOREIGN KEY ("companyId") REFERENCES public."Company"("companyId");


--
-- Name: Trip link_Company_Trip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "link_Company_Trip_1" FOREIGN KEY ("companyId") REFERENCES public."Company"("companyId");


--
-- Name: Accommodation link_Country_Accomadation_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Accommodation"
    ADD CONSTRAINT "link_Country_Accomadation_1" FOREIGN KEY (country) REFERENCES public."Country"("countryId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TouristicPlace link_Country_TouristicPlaces_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TouristicPlace"
    ADD CONSTRAINT "link_Country_TouristicPlaces_1" FOREIGN KEY ("countryId") REFERENCES public."Country"("countryId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Trip link_Country_Trip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "link_Country_Trip_1" FOREIGN KEY ("countryId") REFERENCES public."Country"("countryId");


--
-- Name: TourGuide link_Person_TourGuide_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TourGuide"
    ADD CONSTRAINT "link_Person_TourGuide_1" FOREIGN KEY ("personId") REFERENCES public."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Traveler link_Person_Traveler_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Traveler"
    ADD CONSTRAINT "link_Person_Traveler_1" FOREIGN KEY ("personId") REFERENCES public."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Trip link_TourGuide_Trip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Trip"
    ADD CONSTRAINT "link_TourGuide_Trip_1" FOREIGN KEY ("tourGuideId") REFERENCES public."TourGuide"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TripTouristicPlace link_TouristicPlaces_TripTouristicPlace_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "link_TouristicPlaces_TripTouristicPlace_1" FOREIGN KEY ("placeId") REFERENCES public."TouristicPlace"("placeId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review link_Traveler_Review_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "link_Traveler_Review_1" FOREIGN KEY ("travelerId") REFERENCES public."Traveler"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TravelerTrip link_Traveler_TravelerTrip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TravelerTrip"
    ADD CONSTRAINT "link_Traveler_TravelerTrip_1" FOREIGN KEY ("personId") REFERENCES public."Traveler"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Review link_Trip_Review_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "link_Trip_Review_1" FOREIGN KEY ("tripId") REFERENCES public."Trip"("tripId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TravelerTrip link_Trip_TravelerTrip_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TravelerTrip"
    ADD CONSTRAINT "link_Trip_TravelerTrip_1" FOREIGN KEY ("tripId") REFERENCES public."Trip"("tripId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TripTouristicPlace link_Trip_TripTouristicPlace_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TripTouristicPlace"
    ADD CONSTRAINT "link_Trip_TripTouristicPlace_1" FOREIGN KEY ("tripId") REFERENCES public."Trip"("tripId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict s7KST8yyhEDtAJnBfurSgMiAnhW61tUbdPUJPLjQ5O0n7EjnHY1MvEYql5123UT

