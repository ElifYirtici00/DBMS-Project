--
-- PostgreSQL database dump
--

\restrict bj6T0Ya5ktVvw1zqqtmeKL8eNiWZuCjhQQZSTDfeVQCnkhJWBVp7eWlQXmH7qiV

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
-- Name: ReservationCount(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."ReservationCount"(customerid character) RETURNS character
    LANGUAGE plpgsql
    AS $$
DECLARE
    totalReservation INT;
BEGIN
    SELECT COUNT (*)
    INTO totalReservation FROM "Reservation"
    WHERE "personID" = customerID;
    RETURN totalReservation;
END;
$$;


ALTER FUNCTION public."ReservationCount"(customerid character) OWNER TO postgres;

--
-- Name: calculateTotalAmount(date, date, money); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."calculateTotalAmount"(checkindate date, checkoutdate date, price money) RETURNS money
    LANGUAGE plpgsql
    AS $$
DECLARE
    amount MONEY;
    totalDay INT;
BEGIN
    totalDay := checkOUTdate - checkINdate;
    Amount := totalDay * price;
    RETURN amount;
END;
$$;


ALTER FUNCTION public."calculateTotalAmount"(checkindate date, checkoutdate date, price money) OWNER TO postgres;

--
-- Name: checkDatesTrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."checkDatesTrigger"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."checkOUTdate" < NEW."checkINdate" THEN
        RAISE EXCEPTION 'Hata: Çıkış tarihi, giriş tarihinden önce olamaz!';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."checkDatesTrigger"() OWNER TO postgres;

--
-- Name: checkLoyaltyPointsTrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."checkLoyaltyPointsTrigger"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    customerPoint INTEGER;
BEGIN
    SELECT "loyaltyPoints" INTO customerPoint
    FROM "Customer"
    WHERE "personID" = NEW."personID";

    IF customerPoint IS NOT NULL AND customerPoint < 50 THEN       
        INSERT INTO "reservationCanceled"("personID", "depositPrice")
        VALUES(NEW."personID", NEW."totalAmount");
        NEW."totalAmount" = 0;      
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."checkLoyaltyPointsTrigger"() OWNER TO postgres;

--
-- Name: checkReservationDateTrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."checkReservationDateTrigger"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."checkOUTdate" < NEW."checkINdate" THEN
        RETURN NULL; 
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."checkReservationDateTrigger"() OWNER TO postgres;

--
-- Name: checkRoomStatusTrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."checkRoomStatusTrigger"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD."status" = 'full' AND NEW."reservationNumber" IS NOT NULL THEN
        NEW."reservationNumber" = NULL; 
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."checkRoomStatusTrigger"() OWNER TO postgres;

--
-- Name: dailyPrice(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."dailyPrice"(roomtypename text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    dailyPrice MONEY;
BEGIN
    SELECT "price" INTO dailyPrice  FROM "RoomType"
    WHERE "typeName" = RoomTypeName;
    RETURN dailyPrice;
END;
$$;


ALTER FUNCTION public."dailyPrice"(roomtypename text) OWNER TO postgres;

--
-- Name: roomStatusChangingTrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."roomStatusChangingTrigger"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."status" <> OLD."status" THEN
        INSERT INTO "roomStatusLogs"("roomID", "oldStatus", "newStatus", "updateDate")
        VALUES(OLD."roomID", OLD."status", NEW."status", CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."roomStatusChangingTrigger"() OWNER TO postgres;

--
-- Name: showDepositPrice(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."showDepositPrice"(customerid character) RETURNS character
    LANGUAGE plpgsql
    AS $$
DECLARE
    cashback MONEY;
BEGIN
    SELECT "depositPrice" INTO cashback FROM "reservationCanceled"
    WHERE "personID" = customerID;
    RETURN cashback;
END;
$$;


ALTER FUNCTION public."showDepositPrice"(customerid character) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Cleaner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cleaner" (
    "personID" character(1) NOT NULL,
    "roomName" character varying(50)
);


ALTER TABLE public."Cleaner" OWNER TO postgres;

--
-- Name: Customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Customer" (
    "personID" character(1) NOT NULL,
    "passportNumber" character(10) NOT NULL,
    "loyaltyPoints" integer NOT NULL,
    "customerType" character varying(50) NOT NULL
);


ALTER TABLE public."Customer" OWNER TO postgres;

--
-- Name: Department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Department" (
    "departmentNumber" character(10) NOT NULL,
    "departmentName" character varying(50) NOT NULL
);


ALTER TABLE public."Department" OWNER TO postgres;

--
-- Name: Employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Employee" (
    "personID" character(1) NOT NULL,
    "employeeID" character(10) NOT NULL,
    "shiftType" character(10) NOT NULL,
    cleaner character varying(50),
    receptionist character varying(50),
    "departmentNumber" character(10)
);


ALTER TABLE public."Employee" OWNER TO postgres;

--
-- Name: Person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Person" (
    "personID" character(1) NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    customer character varying(50),
    employee character varying(50)
);


ALTER TABLE public."Person" OWNER TO postgres;

--
-- Name: Receptionist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Receptionist" (
    "personID" character(1) NOT NULL,
    "workingTime" character varying(50)
);


ALTER TABLE public."Receptionist" OWNER TO postgres;

--
-- Name: Reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Reservation" (
    "reservationNumber" character(20) NOT NULL,
    "checkINdate" date,
    "checkOUTdate" date,
    "totalAmount" money,
    "personID" character(1)
);


ALTER TABLE public."Reservation" OWNER TO postgres;

--
-- Name: Room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Room" (
    "roomID" character(20) NOT NULL,
    status character varying(50),
    "typeID" character(10),
    "reservationNumber" character(20)
);


ALTER TABLE public."Room" OWNER TO postgres;

--
-- Name: RoomType; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."RoomType" (
    "typeID" character(10) NOT NULL,
    "typeName" character varying(50),
    price money
);


ALTER TABLE public."RoomType" OWNER TO postgres;

--
-- Name: reservationCanceled; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."reservationCanceled" (
    "personID" character(1) CONSTRAINT "reserationCanceled_personID_not_null" NOT NULL,
    "depositPrice" money
);


ALTER TABLE public."reservationCanceled" OWNER TO postgres;

--
-- Name: reservationConfirmed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."reservationConfirmed" (
    "personID" character(1) CONSTRAINT "reserationConfirmed_personID_not_null" NOT NULL,
    "paymentInformation" character varying(50)
);


ALTER TABLE public."reservationConfirmed" OWNER TO postgres;

--
-- Name: roomStatusChanging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."roomStatusChanging" (
    "logID" integer NOT NULL,
    "roomID" character(20) NOT NULL,
    "oldStatus" character varying(50),
    "newStatus" character varying(50),
    "updateDate" date NOT NULL
);


ALTER TABLE public."roomStatusChanging" OWNER TO postgres;

--
-- Name: roomStatusChanging_logID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."roomStatusChanging_logID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."roomStatusChanging_logID_seq" OWNER TO postgres;

--
-- Name: roomStatusChanging_logID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."roomStatusChanging_logID_seq" OWNED BY public."roomStatusChanging"."logID";


--
-- Name: roomStatusChanging logID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."roomStatusChanging" ALTER COLUMN "logID" SET DEFAULT nextval('public."roomStatusChanging_logID_seq"'::regclass);


--
-- Data for Name: Cleaner; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Cleaner" VALUES
	('3', 'Room101'),
	('6', 'Room201'),
	('9', 'Room303');


--
-- Data for Name: Customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Customer" VALUES
	('7', 'A2356     ', 198, 'ReservationConfirmed'),
	('2', 'A2479     ', 12, 'ReservationCanceled'),
	('1', 'A1136     ', 177, 'ReservationConfirmed'),
	('8', 'A1298     ', 36, 'ReservationCanceled');


--
-- Data for Name: Department; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Department" VALUES
	('DP01      ', 'CleaningDepartment'),
	('DP02      ', 'ManagementDepartment');


--
-- Data for Name: Employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Employee" VALUES
	('3', 'E001      ', 'PartTime  ', NULL, NULL, 'DP01      '),
	('4', 'E002      ', 'FullTime  ', NULL, NULL, 'DP02      '),
	('5', 'E003      ', 'FullTime  ', NULL, NULL, 'DP02      '),
	('6', 'E004      ', 'PartTime  ', NULL, NULL, 'DP01      '),
	('9', 'E005      ', 'PartTime  ', NULL, NULL, 'DP01      ');


--
-- Data for Name: Person; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Person" VALUES
	('3', 'Alperen', 'Tüfekçi', NULL, NULL),
	('4', 'Okan', 'Arduç', NULL, NULL),
	('5', 'Ali', 'Yılmaz', NULL, NULL),
	('1', 'Ümit', 'Ak', NULL, NULL),
	('2', 'Eren Yusuf', 'Can', NULL, NULL),
	('6', 'Ayşe', 'Dönmez', NULL, NULL),
	('7', 'Elif', 'Holat', NULL, NULL),
	('8', 'Ebru', 'Timur', NULL, NULL),
	('9', 'Sefa', 'Ak', NULL, NULL);


--
-- Data for Name: Receptionist; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Receptionist" VALUES
	('4', '12hours'),
	('5', '8hours');


--
-- Data for Name: Reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Reservation" VALUES
	('Reservation001      ', '2025-07-17', '2025-07-20', '$3,000.00', '1'),
	('Reservation002      ', '2025-07-23', '2025-07-30', '$0.00', '2'),
	('Reservation004      ', '2025-07-12', '2025-07-20', '$0.00', '8'),
	('Reservation003      ', '2025-07-01', '2025-07-23', '$5,500.00', '7'),
	('Reservation005      ', '2025-07-06', '2025-07-12', '$0.00', '1');


--
-- Data for Name: Room; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Room" VALUES
	('Room101             ', 'avaliable', 'R001      ', 'Reservation001      '),
	('Room201             ', 'cleaning', 'R002      ', 'Reservation002      '),
	('Room102             ', 'cleaning', 'R001      ', NULL),
	('Room103             ', 'full', 'R001      ', NULL),
	('Room203             ', 'full', 'R002      ', NULL),
	('Room303             ', 'cleaning', 'R003      ', NULL),
	('Room301             ', 'full', 'R003      ', 'Reservation004      '),
	('Room202             ', 'avaliable', 'R002      ', 'Reservation003      '),
	('Room302             ', 'avaliable', 'R003      ', 'Reservation005      ');


--
-- Data for Name: RoomType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."RoomType" VALUES
	('R001      ', 'Suit', '$750.00'),
	('R002      ', 'Single', '$250.00'),
	('R003      ', 'Double', '$500.00');


--
-- Data for Name: reservationCanceled; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."reservationCanceled" VALUES
	('2', '$1,750.00'),
	('8', '$4,000.00'),
	('1', '$3,000.00');


--
-- Data for Name: reservationConfirmed; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."reservationConfirmed" VALUES
	('1', 'successfully'),
	('7', 'half-price was taken');


--
-- Data for Name: roomStatusChanging; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: roomStatusChanging_logID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."roomStatusChanging_logID_seq"', 1, false);


--
-- Name: Cleaner cleanerPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cleaner"
    ADD CONSTRAINT "cleanerPK" PRIMARY KEY ("personID");


--
-- Name: Customer customerPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "customerPK" PRIMARY KEY ("personID");


--
-- Name: Department departmentPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Department"
    ADD CONSTRAINT "departmentPK" PRIMARY KEY ("departmentNumber");


--
-- Name: Employee employeePK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "employeePK" PRIMARY KEY ("personID");


--
-- Name: Person personPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Person"
    ADD CONSTRAINT "personPK" PRIMARY KEY ("personID");


--
-- Name: Receptionist receptionistPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Receptionist"
    ADD CONSTRAINT "receptionistPK" PRIMARY KEY ("personID");


--
-- Name: reservationCanceled reserationCanceledPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reservationCanceled"
    ADD CONSTRAINT "reserationCanceledPK" PRIMARY KEY ("personID");


--
-- Name: reservationConfirmed reserationConfirmedPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reservationConfirmed"
    ADD CONSTRAINT "reserationConfirmedPK" PRIMARY KEY ("personID");


--
-- Name: Reservation reservationPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reservation"
    ADD CONSTRAINT "reservationPK" PRIMARY KEY ("reservationNumber");


--
-- Name: Room roomPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Room"
    ADD CONSTRAINT "roomPK" PRIMARY KEY ("roomID");


--
-- Name: roomStatusChanging roomStatusChangingPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."roomStatusChanging"
    ADD CONSTRAINT "roomStatusChangingPK" PRIMARY KEY ("logID");


--
-- Name: RoomType roomTypePK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."RoomType"
    ADD CONSTRAINT "roomTypePK" PRIMARY KEY ("typeID");


--
-- Name: Reservation checkingLoyaltyPoints; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "checkingLoyaltyPoints" BEFORE INSERT ON public."Reservation" FOR EACH ROW EXECUTE FUNCTION public."checkLoyaltyPointsTrigger"();


--
-- Name: Room preventBookingFullRoom; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "preventBookingFullRoom" BEFORE UPDATE ON public."Room" FOR EACH ROW EXECUTE FUNCTION public."checkRoomStatusTrigger"();


--
-- Name: Reservation preventEnteringWrongDate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "preventEnteringWrongDate" BEFORE INSERT OR UPDATE ON public."Reservation" FOR EACH ROW EXECUTE FUNCTION public."checkReservationDateTrigger"();


--
-- Name: Room roomStatusChanging; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "roomStatusChanging" BEFORE UPDATE ON public."Room" FOR EACH ROW EXECUTE FUNCTION public."roomStatusChangingTrigger"();


--
-- Name: Cleaner cleanerFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cleaner"
    ADD CONSTRAINT "cleanerFK" FOREIGN KEY ("personID") REFERENCES public."Employee"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: Customer customerFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "customerFK" FOREIGN KEY ("personID") REFERENCES public."Person"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: Employee employeeFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "employeeFK" FOREIGN KEY ("personID") REFERENCES public."Person"("personID") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Employee employeeFK2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "employeeFK2" FOREIGN KEY ("departmentNumber") REFERENCES public."Department"("departmentNumber") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Receptionist receptionistFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Receptionist"
    ADD CONSTRAINT "receptionistFK" FOREIGN KEY ("personID") REFERENCES public."Employee"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: reservationCanceled reserationCanceledFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reservationCanceled"
    ADD CONSTRAINT "reserationCanceledFK" FOREIGN KEY ("personID") REFERENCES public."Customer"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: reservationConfirmed reserationConfirmedFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."reservationConfirmed"
    ADD CONSTRAINT "reserationConfirmedFK" FOREIGN KEY ("personID") REFERENCES public."Customer"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: Reservation reservationFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Reservation"
    ADD CONSTRAINT "reservationFK" FOREIGN KEY ("personID") REFERENCES public."Customer"("personID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: Room roomFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Room"
    ADD CONSTRAINT "roomFK" FOREIGN KEY ("typeID") REFERENCES public."RoomType"("typeID") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: Room roomFK2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Room"
    ADD CONSTRAINT "roomFK2" FOREIGN KEY ("reservationNumber") REFERENCES public."Reservation"("reservationNumber") ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- PostgreSQL database dump complete
--

\unrestrict bj6T0Ya5ktVvw1zqqtmeKL8eNiWZuCjhQQZSTDfeVQCnkhJWBVp7eWlQXmH7qiV

