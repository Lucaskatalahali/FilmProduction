--
-- PostgreSQL database dump
--

--\restrict ezXM9p9Ptfaf5zJg42lwu3gjneCeZAnChrOQrFIbzcsLvFvh9nwvBr1TRqPBTkq

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-10 00:57:18

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
-- TOC entry 6 (class 2615 OID 24702)
-- Name: person; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA person;


ALTER SCHEMA person OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 25235)
-- Name: assign_roles(); Type: FUNCTION; Schema: person; Owner: postgres
--

CREATE FUNCTION person.assign_roles() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- LÓGICA DE UPDATE (Remoção)
    IF TG_OP = 'UPDATE' THEN
        -- Se o diretor foi desmarcado (OLD.director TRUE e NEW.director FALSE), DELETA
        IF OLD.director AND NOT NEW.director THEN
            DELETE FROM person."Director" WHERE "personId" = OLD."personId";
        END IF;

        -- Se o ator foi desmarcado
        IF OLD.actor AND NOT NEW.actor THEN
            DELETE FROM person."Actor" WHERE "personId" = OLD."personId";
        END IF;


        IF OLD.producer AND NOT NEW.producer THEN
            DELETE FROM person."Producer" WHERE "personId" = OLD."personId";
        END IF;

        IF OLD."crewMember" AND NOT NEW."crewMember" THEN
            DELETE FROM person."CrewMember" WHERE "personId" = OLD."personId";
        END IF;
    END IF;

    -- LÓGICA DE INSERT/ADIÇÃO (Permanece a mesma, garantindo que o registro exista)
    -- Isso trata novos INSERTs e UPDATEs de FALSE para TRUE.
    IF NEW.actor THEN
        INSERT INTO person."Actor"("personId") VALUES (NEW."personId") ON CONFLICT DO NOTHING;
    END IF;

    IF NEW.director THEN
        INSERT INTO person."Director"("personId") VALUES (NEW."personId") ON CONFLICT DO NOTHING;
    END IF;


    IF NEW.producer THEN
        INSERT INTO person."Producer"("personId") VALUES (NEW."personId") ON CONFLICT DO NOTHING;
    END IF;

    IF NEW."crewMember" THEN
        INSERT INTO person."CrewMember"("personId") VALUES (NEW."personId") ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION person.assign_roles() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 25142)
-- Name: check_duration_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_duration_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Filmin müddəti (duration) 5 dəqiqədən az olarsa
    IF NEW.duration < INTERVAL '5 minutes' THEN
        RAISE EXCEPTION 'Duration is too little. It mustbemaximum 5 minutes.';
    END IF;

    -- Filmin müddəti 6 saatdan (360 dəqiqədən) çox olarsa
    IF NEW.duration > INTERVAL '6 hours' THEN
        RAISE EXCEPTION 'Duration is a lot!It can be maximuun 6 hours.';
    END IF;
    
    -- Yoxlamalar uğurlu olarsa, qeydin əlavə edilməsinə/dəyişdirilməsinə icazə ver
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_duration_limit() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 25156)
-- Name: check_film_category_required(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_film_category_required() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Eyni anda hər iki sahə (live-action VƏ animation) FALSE (yox) olarsa xəta at
    IF (NEW."liveAction" IS NOT TRUE AND NEW."animation" IS NOT TRUE) THEN
        RAISE EXCEPTION 'A film must have at least one category.';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_film_category_required() OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 25241)
-- Name: get_complete_film_info(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_complete_film_info(p_filmid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        -- FILM MAIN INFO
        'filmId', f."filmId",
        'title', f.title,
        'duration', f.duration,
        'imdb', f.imdb,

        'animation', f.animation,
        'liveAction', f."liveAction",

        -- PRODUCTION COMPANY
        'productionCompany', pc."name",

        -- GENRES
        'genres', (
            SELECT json_agg(g.name)
            FROM public."FilmGenre" fg
            JOIN public."Genre" g ON g."genreId" = fg."genreId"
            WHERE fg."filmId" = f."filmId"
        ),

        -- PLACES FILMED
        'places', (
            SELECT json_agg(p.name)
            FROM public."FilmPlace" fp
            JOIN public."Place" p ON fp."placeId" = p."placeId"
            WHERE fp."filmId" = f."filmId"
        ),

        -- ACTORS
        'actors', (
            SELECT json_agg(per.name || ' ' || per.surname)
            FROM public."ActorFilm" af
            JOIN person."Actor" a ON af."personId" = a."personId"
            JOIN person."Person" per ON per."personId" = a."personId"
            WHERE af."filmId" = f."filmId"
        ),

        -- DIRECTORS
        'directors', (
            SELECT json_agg(per.name || ' ' || per.surname)
            FROM public."DirectorFilm" df
            JOIN person."Director" d ON df."personId" = d."personId"
            JOIN person."Person" per ON per."personId" = d."personId"
            WHERE df."filmId" = f."filmId"
        ),

        -- PRODUCERS
        'producers', (
            SELECT json_agg(per.name || ' ' || per.surname)
            FROM public."ProducerFilm" pf
            JOIN person."Producer" p ON pf."personId" = p."personId"
            JOIN person."Person" per ON per."personId" = p."personId"
            WHERE pf."filmId" = f."filmId"
        ),

        -- CREW MEMBERS
        'crewMembers', (
            SELECT json_agg(per.name || ' ' || per.surname)
            FROM public."CrewMemberFilm" cf
            JOIN person."CrewMember" c ON cf."personId" = c."personId"
            JOIN person."Person" per ON per."personId" = c."personId"
            WHERE cf."filmId" = f."filmId"
        )
    )
    INTO result
    FROM public."Film" f
    LEFT JOIN public."ProductionCompany" pc ON pc."companyId" = f."companyId"
    WHERE f."filmId" = p_filmId;

    RETURN result;
END;
$$;


ALTER FUNCTION public.get_complete_film_info(p_filmid integer) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 25217)
-- Name: get_film_releases_by_film(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_film_releases_by_film(p_filmid integer) RETURNS TABLE(country character varying, date date, "ageLimit" integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT fr.country, fr.date,fr."ageLimit"
    FROM public."FilmRelease" fr
    WHERE fr."filmId" = p_filmId;
END;
$$;


ALTER FUNCTION public.get_film_releases_by_film(p_filmid integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 25213)
-- Name: get_films_by_min_score_simple(numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_films_by_min_score_simple(min_score numeric) RETURNS TABLE("Film name" character varying, imdb numeric)
    LANGUAGE sql
    AS $$
    SELECT
        F.title,
        F.imdb
    FROM
        public."Film" F
    WHERE
        F.imdb >= min_score -- Reytinqi minimum dəyərdən böyük və ya bərabər
    ORDER BY
        F.imdb DESC;
$$;


ALTER FUNCTION public.get_films_by_min_score_simple(min_score numeric) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 26042)
-- Name: get_person_full_info(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.get_person_full_info(IN p_personid integer, OUT result json)
    LANGUAGE plpgsql
    AS $$
DECLARE
    base_info JSONB := '{}'::jsonb;
    roles JSONB := '{}'::jsonb;
    film_list JSONB;
BEGIN
    -- ====== 1. MAIN PERSON INFO ======
    SELECT jsonb_build_object(
        'name', per.name,
        'surname', per.surname,
        'birthDate', per."birthDate",
        'nationality', per.nationality
    )
    INTO base_info
    FROM person."Person" per
    WHERE per."personId" = p_personId;

    -- ====== 2. ACTOR ======
    IF EXISTS(SELECT 1 FROM person."Actor" WHERE "personId" = p_personId) THEN
        SELECT jsonb_agg(f.title)
        INTO film_list
        FROM public."ActorFilm" af
        JOIN public."Film" f ON f."filmId" = af."filmId"
        WHERE af."personId" = p_personId;

        roles := roles || jsonb_build_object('actor', film_list);
    END IF;

    -- ====== 3. DIRECTOR ======
    IF EXISTS(SELECT 1 FROM person."Director" WHERE "personId" = p_personId) THEN
        SELECT jsonb_agg(f.title)
        INTO film_list
        FROM public."DirectorFilm" df
        JOIN public."Film" f ON f."filmId" = df."filmId"
        WHERE df."personId" = p_personId;

        roles := roles || jsonb_build_object('director', film_list);
    END IF;

    -- ====== 4. PRODUCER ======
    IF EXISTS(SELECT 1 FROM person."Producer" WHERE "personId" = p_personId) THEN
        SELECT jsonb_agg(f.title)
        INTO film_list
        FROM public."ProducerFilm" pf
        JOIN public."Film" f ON f."filmId" = pf."filmId"
        WHERE pf."personId" = p_personId;

        roles := roles || jsonb_build_object('producer', film_list);
    END IF;

    -- ====== 5. CREW MEMBER ======
    IF EXISTS(SELECT 1 FROM person."CrewMember" WHERE "personId" = p_personId) THEN
        SELECT jsonb_agg(f.title)
        INTO film_list
        FROM public."CrewMemberFilm" cf
        JOIN public."Film" f ON f."filmId" = cf."filmId"
        WHERE cf."personId" = p_personId;

        roles := roles || jsonb_build_object('crewMember', film_list);
    END IF;

    -- ====== 6. FINAL JSON (MAIN INFO + ROLES) ======
    result := (base_info || jsonb_build_object('roles', roles))::json;
END;
$$;


ALTER PROCEDURE public.get_person_full_info(IN p_personid integer, OUT result json) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 25211)
-- Name: handle_category_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_category_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- 1. ANIMATION cədvəlindən sil
    IF OLD.animation IS TRUE THEN
        DELETE FROM public."Animation"
        WHERE "filmId" = OLD."filmId";
    END IF;

    -- 2. LIVE-ACTION cədvəlindən sil
    IF OLD."liveAction" IS TRUE THEN
        DELETE FROM public."LiveAction"
        WHERE "filmId" = OLD."filmId";
    END IF;
    
    -- DELETE triggerlərində DELETE əməliyyatının davam etməsi üçün OLD qaytarılır
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.handle_category_delete() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 25158)
-- Name: handle_category_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_category_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- 1. ANIMATION üçün idarəetmə
    IF NEW.animation IS TRUE THEN
        -- Əgər animation TRUE isə, Animation cədvəlinə daxil et
        INSERT INTO public."Animation" ("filmId")
        VALUES (NEW."filmId")
        ON CONFLICT ("filmId") DO NOTHING;
    ELSIF NEW.animation IS NOT TRUE AND OLD.animation IS TRUE THEN
        -- Əgər animation FALSE olaraq dəyişibsə, Animation cədvəlindən sil
        DELETE FROM public."Animation" WHERE "filmId" = NEW."filmId";
    END IF;

    -- 2. LIVE-ACTION üçün idarəetmə
    IF NEW."liveAction" IS TRUE THEN
        -- Əgər live-action TRUE isə, LiveAction cədvəlinə daxil et
        INSERT INTO public."LiveAction" ("filmId")
        VALUES (NEW."filmId")
        ON CONFLICT ("filmId") DO NOTHING;
    ELSIF NEW."liveAction" IS NOT TRUE AND OLD."liveAction" IS TRUE THEN
        -- Əgər live-action FALSE olaraq dəyişibsə, LiveAction cədvəlindən sil
        DELETE FROM public."LiveAction" WHERE "filmId" = NEW."filmId";
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_category_insert() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 24747)
-- Name: Actor; Type: TABLE; Schema: person; Owner: postgres
--

CREATE TABLE person."Actor" (
    "personId" integer NOT NULL
);


ALTER TABLE person."Actor" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24765)
-- Name: CrewMember; Type: TABLE; Schema: person; Owner: postgres
--

CREATE TABLE person."CrewMember" (
    "personId" integer NOT NULL
);


ALTER TABLE person."CrewMember" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24759)
-- Name: Director; Type: TABLE; Schema: person; Owner: postgres
--

CREATE TABLE person."Director" (
    "personId" integer NOT NULL
);


ALTER TABLE person."Director" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24726)
-- Name: Person; Type: TABLE; Schema: person; Owner: postgres
--

CREATE TABLE person."Person" (
    "personId" integer NOT NULL,
    name character varying(50) CONSTRAINT "Person_firstName_not_null" NOT NULL,
    surname character varying(50) CONSTRAINT "Person_lastName_not_null" NOT NULL,
    "birthDate" date,
    nationality character varying(40),
    actor boolean DEFAULT false,
    producer boolean DEFAULT false,
    director boolean DEFAULT false,
    "crewMember" boolean DEFAULT false
);


ALTER TABLE person."Person" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24725)
-- Name: Person_personId_seq; Type: SEQUENCE; Schema: person; Owner: postgres
--

CREATE SEQUENCE person."Person_personId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE person."Person_personId_seq" OWNER TO postgres;

--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 222
-- Name: Person_personId_seq; Type: SEQUENCE OWNED BY; Schema: person; Owner: postgres
--

ALTER SEQUENCE person."Person_personId_seq" OWNED BY person."Person"."personId";


--
-- TOC entry 225 (class 1259 OID 24753)
-- Name: Producer; Type: TABLE; Schema: person; Owner: postgres
--

CREATE TABLE person."Producer" (
    "personId" integer NOT NULL
);


ALTER TABLE person."Producer" OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 25218)
-- Name: ActorFilm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ActorFilm" (
    "personId" integer NOT NULL,
    "filmId" integer NOT NULL
);


ALTER TABLE public."ActorFilm" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 24870)
-- Name: Animation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Animation" (
    "filmId" integer NOT NULL
);


ALTER TABLE public."Animation" OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 25273)
-- Name: CrewMemberFilm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CrewMemberFilm" (
    "personId" integer NOT NULL,
    "filmId" integer NOT NULL
);


ALTER TABLE public."CrewMemberFilm" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 25074)
-- Name: DirectorFilm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DirectorFilm" (
    "personId" integer NOT NULL,
    "filmId" integer NOT NULL
);


ALTER TABLE public."DirectorFilm" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24855)
-- Name: Film; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Film" (
    "filmId" integer NOT NULL,
    title character(50) NOT NULL,
    imdb numeric(2,1),
    "companyId" integer,
    duration interval,
    animation boolean DEFAULT false CONSTRAINT "Film_animatio_not_null" NOT NULL,
    "liveAction" boolean DEFAULT false CONSTRAINT "Film_liveActio_not_null" NOT NULL
);


ALTER TABLE public."Film" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 24988)
-- Name: FilmGenre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FilmGenre" (
    "filmId" integer CONSTRAINT "FılmGenre_fılmId_not_null" NOT NULL,
    "genreId" integer CONSTRAINT "FılmGenre_genreId_not_null" NOT NULL
);


ALTER TABLE public."FilmGenre" OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 24953)
-- Name: FilmPlace; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FilmPlace" (
    "filmId" integer NOT NULL,
    "placeId" integer NOT NULL
);


ALTER TABLE public."FilmPlace" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 24951)
-- Name: FilmPlace_filmId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."FilmPlace_filmId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."FilmPlace_filmId_seq" OWNER TO postgres;

--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 238
-- Name: FilmPlace_filmId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FilmPlace_filmId_seq" OWNED BY public."FilmPlace"."filmId";


--
-- TOC entry 239 (class 1259 OID 24952)
-- Name: FilmPlace_placeId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."FilmPlace_placeId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."FilmPlace_placeId_seq" OWNER TO postgres;

--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 239
-- Name: FilmPlace_placeId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."FilmPlace_placeId_seq" OWNED BY public."FilmPlace"."placeId";


--
-- TOC entry 237 (class 1259 OID 24918)
-- Name: FilmRelease; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."FilmRelease" (
    "releaseId" integer NOT NULL,
    country character varying(50) NOT NULL,
    date date,
    "ageLimit" integer,
    "filmId" integer NOT NULL
);


ALTER TABLE public."FilmRelease" OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 24917)
-- Name: FilmRelease_releaseId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."FilmRelease" ALTER COLUMN "releaseId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."FilmRelease_releaseId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 24854)
-- Name: Film_filmId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Film" ALTER COLUMN "filmId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Film_filmId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 24693)
-- Name: Genre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Genre" (
    "genreId" integer NOT NULL,
    name character varying(40) NOT NULL
);


ALTER TABLE public."Genre" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 24692)
-- Name: Genre_genreId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Genre_genreId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Genre_genreId_seq" OWNER TO postgres;

--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 220
-- Name: Genre_genreId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Genre_genreId_seq" OWNED BY public."Genre"."genreId";


--
-- TOC entry 246 (class 1259 OID 25297)
-- Name: Genre_genreId_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Genre" ALTER COLUMN "genreId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Genre_genreId_seq1"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 24864)
-- Name: LiveAction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LiveAction" (
    "filmId" integer NOT NULL
);


ALTER TABLE public."LiveAction" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 24911)
-- Name: Place; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Place" (
    name character varying(50),
    "placeId" integer CONSTRAINT "Place_palceId_not_null" NOT NULL
);


ALTER TABLE public."Place" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 24910)
-- Name: Place_palceId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Place" ALTER COLUMN "placeId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Place_palceId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 243 (class 1259 OID 25108)
-- Name: ProducerFilm; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProducerFilm" (
    "personId" integer NOT NULL,
    "filmId" integer NOT NULL
);


ALTER TABLE public."ProducerFilm" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 24895)
-- Name: ProductionCompany; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductionCompany" (
    "companyId" integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public."ProductionCompany" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 24894)
-- Name: ProductionCompany_companyId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."ProductionCompany" ALTER COLUMN "companyId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."ProductionCompany_companyId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4841 (class 2604 OID 24729)
-- Name: Person personId; Type: DEFAULT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Person" ALTER COLUMN "personId" SET DEFAULT nextval('person."Person_personId_seq"'::regclass);


--
-- TOC entry 4848 (class 2604 OID 24956)
-- Name: FilmPlace filmId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmPlace" ALTER COLUMN "filmId" SET DEFAULT nextval('public."FilmPlace_filmId_seq"'::regclass);


--
-- TOC entry 4849 (class 2604 OID 24957)
-- Name: FilmPlace placeId; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmPlace" ALTER COLUMN "placeId" SET DEFAULT nextval('public."FilmPlace_placeId_seq"'::regclass);


--
-- TOC entry 5060 (class 0 OID 24747)
-- Dependencies: 224
-- Data for Name: Actor; Type: TABLE DATA; Schema: person; Owner: postgres
--

INSERT INTO person."Actor" VALUES (1);
INSERT INTO person."Actor" VALUES (3);
INSERT INTO person."Actor" VALUES (6);
INSERT INTO person."Actor" VALUES (8);
INSERT INTO person."Actor" VALUES (11);
INSERT INTO person."Actor" VALUES (12);
INSERT INTO person."Actor" VALUES (15);


--
-- TOC entry 5063 (class 0 OID 24765)
-- Dependencies: 227
-- Data for Name: CrewMember; Type: TABLE DATA; Schema: person; Owner: postgres
--

INSERT INTO person."CrewMember" VALUES (5);
INSERT INTO person."CrewMember" VALUES (9);
INSERT INTO person."CrewMember" VALUES (11);


--
-- TOC entry 5062 (class 0 OID 24759)
-- Dependencies: 226
-- Data for Name: Director; Type: TABLE DATA; Schema: person; Owner: postgres
--

INSERT INTO person."Director" VALUES (1);
INSERT INTO person."Director" VALUES (4);
INSERT INTO person."Director" VALUES (8);
INSERT INTO person."Director" VALUES (10);
INSERT INTO person."Director" VALUES (14);
INSERT INTO person."Director" VALUES (15);


--
-- TOC entry 5059 (class 0 OID 24726)
-- Dependencies: 223
-- Data for Name: Person; Type: TABLE DATA; Schema: person; Owner: postgres
--

INSERT INTO person."Person" VALUES (1, 'Leonardo', 'Silva', '1974-11-11', 'American', true, false, true, false);
INSERT INTO person."Person" VALUES (2, 'Maria', 'Santos', '1980-03-20', 'Brazilian', false, true, false, false);
INSERT INTO person."Person" VALUES (3, 'Julia', 'Oliveira', '1990-07-25', 'Portuguese', true, false, false, false);
INSERT INTO person."Person" VALUES (4, 'David', 'Mendes', '1965-08-30', 'British', false, false, true, false);
INSERT INTO person."Person" VALUES (5, 'Ana', 'Costa', '1995-01-15', 'French', false, false, false, true);
INSERT INTO person."Person" VALUES (7, 'Sofia', 'Fernandes', '2001-12-01', 'Italian', false, false, false, false);
INSERT INTO person."Person" VALUES (8, 'Chris', 'Jones', '1970-02-02', 'Canadian', true, true, true, false);
INSERT INTO person."Person" VALUES (9, 'Emily', 'Clark', '1988-06-18', 'Australian', false, false, false, true);
INSERT INTO person."Person" VALUES (10, 'Jorge', 'Rocha', '1978-04-12', 'Mexican', false, true, true, false);
INSERT INTO person."Person" VALUES (11, 'Isabela', 'Pires', '1992-09-05', 'Argentinian', true, false, false, true);
INSERT INTO person."Person" VALUES (12, 'Rafael', 'Gomes', '1983-11-20', 'Brazilian', true, false, false, false);
INSERT INTO person."Person" VALUES (13, 'Camila', 'Ferreira', '1975-01-28', 'American', false, true, false, false);
INSERT INTO person."Person" VALUES (14, 'Rui', 'Barbosa', '1960-10-07', 'Portuguese', false, false, true, false);
INSERT INTO person."Person" VALUES (15, 'Miguel', 'Dias', '1991-03-14', 'Spanish', true, false, true, false);
INSERT INTO person."Person" VALUES (6, 'Pedro Lucas Da Costa', 'Alves', '1985-05-10', 'Spanish', true, true, false, false);


--
-- TOC entry 5061 (class 0 OID 24753)
-- Dependencies: 225
-- Data for Name: Producer; Type: TABLE DATA; Schema: person; Owner: postgres
--

INSERT INTO person."Producer" VALUES (2);
INSERT INTO person."Producer" VALUES (6);
INSERT INTO person."Producer" VALUES (8);
INSERT INTO person."Producer" VALUES (10);
INSERT INTO person."Producer" VALUES (13);


--
-- TOC entry 5080 (class 0 OID 25218)
-- Dependencies: 244
-- Data for Name: ActorFilm; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ActorFilm" VALUES (3, 2);
INSERT INTO public."ActorFilm" VALUES (6, 2);


--
-- TOC entry 5067 (class 0 OID 24870)
-- Dependencies: 231
-- Data for Name: Animation; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Animation" VALUES (2);
INSERT INTO public."Animation" VALUES (4);
INSERT INTO public."Animation" VALUES (6);
INSERT INTO public."Animation" VALUES (8);
INSERT INTO public."Animation" VALUES (10);
INSERT INTO public."Animation" VALUES (17);
INSERT INTO public."Animation" VALUES (19);
INSERT INTO public."Animation" VALUES (21);
INSERT INTO public."Animation" VALUES (22);


--
-- TOC entry 5081 (class 0 OID 25273)
-- Dependencies: 245
-- Data for Name: CrewMemberFilm; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5078 (class 0 OID 25074)
-- Dependencies: 242
-- Data for Name: DirectorFilm; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."DirectorFilm" VALUES (4, 2);


--
-- TOC entry 5065 (class 0 OID 24855)
-- Dependencies: 229
-- Data for Name: Film; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (2, 'Spirited Away                                     ', 8.6, NULL, '02:05:00', true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (3, 'The Dark Knight                                   ', 9.0, NULL, '02:32:00', false, true);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (4, 'Toy Story                                         ', 8.3, NULL, '01:21:00', true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (5, 'Interstellar                                      ', 8.6, NULL, '02:49:00', false, true);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (7, 'The Matrix                                        ', 8.7, NULL, '02:16:00', false, true);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (8, 'Finding Nemo                                      ', 8.1, NULL, '01:40:00', true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (9, 'Avatar                                            ', 7.9, NULL, '02:42:00', false, true);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (10, 'Shrek                                             ', 7.9, NULL, '01:29:00', true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (6, 'The Lion King                                     ', 8.5, 1, '01:28:00', true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (17, 'Rango                                             ', NULL, NULL, NULL, true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (19, 'Rango 2                                           ', NULL, NULL, NULL, true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (21, 'Rango 2                                           ', 1.0, NULL, NULL, true, false);
INSERT INTO public."Film" OVERRIDING SYSTEM VALUE VALUES (22, 'Rango                                             ', NULL, NULL, '01:00:00', true, false);


--
-- TOC entry 5077 (class 0 OID 24988)
-- Dependencies: 241
-- Data for Name: FilmGenre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."FilmGenre" VALUES (2, 3);
INSERT INTO public."FilmGenre" VALUES (2, 2);


--
-- TOC entry 5076 (class 0 OID 24953)
-- Dependencies: 240
-- Data for Name: FilmPlace; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."FilmPlace" VALUES (2, 3);
INSERT INTO public."FilmPlace" VALUES (2, 1);


--
-- TOC entry 5073 (class 0 OID 24918)
-- Dependencies: 237
-- Data for Name: FilmRelease; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."FilmRelease" OVERRIDING SYSTEM VALUE VALUES (3, 'Japan', '2001-07-20', 10, 2);
INSERT INTO public."FilmRelease" OVERRIDING SYSTEM VALUE VALUES (4, 'UK', '2003-09-12', 12, 2);


--
-- TOC entry 5057 (class 0 OID 24693)
-- Dependencies: 221
-- Data for Name: Genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Genre" OVERRIDING SYSTEM VALUE VALUES (1, 'Action');
INSERT INTO public."Genre" OVERRIDING SYSTEM VALUE VALUES (2, 'Science Fiction');
INSERT INTO public."Genre" OVERRIDING SYSTEM VALUE VALUES (3, 'Adventure');


--
-- TOC entry 5066 (class 0 OID 24864)
-- Dependencies: 230
-- Data for Name: LiveAction; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."LiveAction" VALUES (3);
INSERT INTO public."LiveAction" VALUES (5);
INSERT INTO public."LiveAction" VALUES (7);
INSERT INTO public."LiveAction" VALUES (9);


--
-- TOC entry 5071 (class 0 OID 24911)
-- Dependencies: 235
-- Data for Name: Place; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Place" OVERRIDING SYSTEM VALUE VALUES ('Estúdio Principal XYZ', 1);
INSERT INTO public."Place" OVERRIDING SYSTEM VALUE VALUES ('Cenário Desértico - Bloco 4', 2);
INSERT INTO public."Place" OVERRIDING SYSTEM VALUE VALUES ('Antiga Estação Ferroviária', 3);
INSERT INTO public."Place" OVERRIDING SYSTEM VALUE VALUES ('Mansão Histórica de Pirenópolis', 4);
INSERT INTO public."Place" OVERRIDING SYSTEM VALUE VALUES ('Prédio da Produção - Escritório', 5);


--
-- TOC entry 5079 (class 0 OID 25108)
-- Dependencies: 243
-- Data for Name: ProducerFilm; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5069 (class 0 OID 24895)
-- Dependencies: 233
-- Data for Name: ProductionCompany; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ProductionCompany" OVERRIDING SYSTEM VALUE VALUES (1, 'Warner Bros. Pictures');
INSERT INTO public."ProductionCompany" OVERRIDING SYSTEM VALUE VALUES (2, 'Pixar Animation Studios');
INSERT INTO public."ProductionCompany" OVERRIDING SYSTEM VALUE VALUES (3, 'Walt Disney Pictures');
INSERT INTO public."ProductionCompany" OVERRIDING SYSTEM VALUE VALUES (4, 'Paramount Pictures');
INSERT INTO public."ProductionCompany" OVERRIDING SYSTEM VALUE VALUES (5, '20th Century Studios');


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 222
-- Name: Person_personId_seq; Type: SEQUENCE SET; Schema: person; Owner: postgres
--

SELECT pg_catalog.setval('person."Person_personId_seq"', 15, true);


--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 238
-- Name: FilmPlace_filmId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FilmPlace_filmId_seq"', 1, false);


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 239
-- Name: FilmPlace_placeId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FilmPlace_placeId_seq"', 1, false);


--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 236
-- Name: FilmRelease_releaseId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."FilmRelease_releaseId_seq"', 5, true);


--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 228
-- Name: Film_filmId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Film_filmId_seq"', 22, true);


--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 220
-- Name: Genre_genreId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Genre_genreId_seq"', 1, false);


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 246
-- Name: Genre_genreId_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Genre_genreId_seq1"', 3, true);


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 234
-- Name: Place_palceId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Place_palceId_seq"', 5, true);


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 232
-- Name: ProductionCompany_companyId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ProductionCompany_companyId_seq"', 5, true);


--
-- TOC entry 4855 (class 2606 OID 24752)
-- Name: Actor ActorPK; Type: CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Actor"
    ADD CONSTRAINT "ActorPK" PRIMARY KEY ("personId");


--
-- TOC entry 4861 (class 2606 OID 24770)
-- Name: CrewMember CrewMemberPK; Type: CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."CrewMember"
    ADD CONSTRAINT "CrewMemberPK" PRIMARY KEY ("personId");


--
-- TOC entry 4859 (class 2606 OID 24764)
-- Name: Director DirectorPK; Type: CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Director"
    ADD CONSTRAINT "DirectorPK" PRIMARY KEY ("personId");


--
-- TOC entry 4853 (class 2606 OID 24734)
-- Name: Person Person_pkey; Type: CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Person"
    ADD CONSTRAINT "Person_pkey" PRIMARY KEY ("personId");


--
-- TOC entry 4857 (class 2606 OID 24758)
-- Name: Producer ProducerPK; Type: CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Producer"
    ADD CONSTRAINT "ProducerPK" PRIMARY KEY ("personId");


--
-- TOC entry 4883 (class 2606 OID 25224)
-- Name: ActorFilm ActorFilm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActorFilm"
    ADD CONSTRAINT "ActorFilm_pkey" PRIMARY KEY ("personId", "filmId");


--
-- TOC entry 4867 (class 2606 OID 24875)
-- Name: Animation AnimationPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Animation"
    ADD CONSTRAINT "AnimationPK" PRIMARY KEY ("filmId");


--
-- TOC entry 4885 (class 2606 OID 25279)
-- Name: CrewMemberFilm CrewMemberFilm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrewMemberFilm"
    ADD CONSTRAINT "CrewMemberFilm_pkey" PRIMARY KEY ("personId", "filmId");


--
-- TOC entry 4879 (class 2606 OID 25080)
-- Name: DirectorFilm DirectorFilm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DirectorFilm"
    ADD CONSTRAINT "DirectorFilm_pkey" PRIMARY KEY ("personId", "filmId");


--
-- TOC entry 4875 (class 2606 OID 24987)
-- Name: FilmPlace FilmPlace_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmPlace"
    ADD CONSTRAINT "FilmPlace_pkey" PRIMARY KEY ("filmId", "placeId");


--
-- TOC entry 4873 (class 2606 OID 24924)
-- Name: FilmRelease FilmRelease_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmRelease"
    ADD CONSTRAINT "FilmRelease_pkey" PRIMARY KEY ("releaseId");


--
-- TOC entry 4863 (class 2606 OID 24863)
-- Name: Film Film_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Film"
    ADD CONSTRAINT "Film_pkey" PRIMARY KEY ("filmId");


--
-- TOC entry 4877 (class 2606 OID 24994)
-- Name: FilmGenre FılmGenre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmGenre"
    ADD CONSTRAINT "FılmGenre_pkey" PRIMARY KEY ("filmId", "genreId");


--
-- TOC entry 4851 (class 2606 OID 24700)
-- Name: Genre GenreId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Genre"
    ADD CONSTRAINT "GenreId" PRIMARY KEY ("genreId");


--
-- TOC entry 4865 (class 2606 OID 24869)
-- Name: LiveAction LiveActionPK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LiveAction"
    ADD CONSTRAINT "LiveActionPK" PRIMARY KEY ("filmId");


--
-- TOC entry 4871 (class 2606 OID 24916)
-- Name: Place Place_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Place"
    ADD CONSTRAINT "Place_pkey" PRIMARY KEY ("placeId");


--
-- TOC entry 4881 (class 2606 OID 25114)
-- Name: ProducerFilm ProducerFilm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProducerFilm"
    ADD CONSTRAINT "ProducerFilm_pkey" PRIMARY KEY ("personId", "filmId");


--
-- TOC entry 4869 (class 2606 OID 24901)
-- Name: ProductionCompany ProductionCompany_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductionCompany"
    ADD CONSTRAINT "ProductionCompany_pkey" PRIMARY KEY ("companyId");


--
-- TOC entry 4904 (class 2620 OID 25236)
-- Name: Person assign_roles_trigger; Type: TRIGGER; Schema: person; Owner: postgres
--

CREATE TRIGGER assign_roles_trigger AFTER INSERT OR UPDATE ON person."Person" FOR EACH ROW EXECUTE FUNCTION person.assign_roles();


--
-- TOC entry 4905 (class 2620 OID 25143)
-- Name: Film trg_check_duration_limit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_duration_limit BEFORE INSERT OR UPDATE OF duration ON public."Film" FOR EACH ROW EXECUTE FUNCTION public.check_duration_limit();


--
-- TOC entry 4906 (class 2620 OID 25157)
-- Name: Film trg_check_film_category; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_film_category BEFORE INSERT OR UPDATE ON public."Film" FOR EACH ROW EXECUTE FUNCTION public.check_film_category_required();


--
-- TOC entry 4907 (class 2620 OID 25212)
-- Name: Film trg_handle_category_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_handle_category_delete BEFORE DELETE ON public."Film" FOR EACH ROW EXECUTE FUNCTION public.handle_category_delete();


--
-- TOC entry 4908 (class 2620 OID 25160)
-- Name: Film trg_handle_category_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_handle_category_insert AFTER INSERT OR UPDATE OF animation, "liveAction" ON public."Film" FOR EACH ROW EXECUTE FUNCTION public.handle_category_insert();


--
-- TOC entry 4886 (class 2606 OID 25033)
-- Name: Actor link_Person_Actor; Type: FK CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Actor"
    ADD CONSTRAINT "link_Person_Actor" FOREIGN KEY ("personId") REFERENCES person."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4889 (class 2606 OID 25006)
-- Name: CrewMember link_Person_CrewMember; Type: FK CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."CrewMember"
    ADD CONSTRAINT "link_Person_CrewMember" FOREIGN KEY ("personId") REFERENCES person."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4888 (class 2606 OID 25018)
-- Name: Director link_Person_Director; Type: FK CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Director"
    ADD CONSTRAINT "link_Person_Director" FOREIGN KEY ("personId") REFERENCES person."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4887 (class 2606 OID 25023)
-- Name: Producer link_Person_Producer; Type: FK CONSTRAINT; Schema: person; Owner: postgres
--

ALTER TABLE ONLY person."Producer"
    ADD CONSTRAINT "link_Person_Producer" FOREIGN KEY ("personId") REFERENCES person."Person"("personId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4900 (class 2606 OID 25225)
-- Name: ActorFilm link_Actor_ActorFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActorFilm"
    ADD CONSTRAINT "link_Actor_ActorFilm" FOREIGN KEY ("personId") REFERENCES person."Actor"("personId") ON DELETE CASCADE;


--
-- TOC entry 4902 (class 2606 OID 25280)
-- Name: CrewMemberFilm link_CrewMember_CrewMemberFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrewMemberFilm"
    ADD CONSTRAINT "link_CrewMember_CrewMemberFilm" FOREIGN KEY ("personId") REFERENCES person."CrewMember"("personId") ON DELETE CASCADE;


--
-- TOC entry 4896 (class 2606 OID 25081)
-- Name: DirectorFilm link_Director_DirectorFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DirectorFilm"
    ADD CONSTRAINT "link_Director_DirectorFilm" FOREIGN KEY ("personId") REFERENCES person."Director"("personId") ON DELETE CASCADE;


--
-- TOC entry 4901 (class 2606 OID 25230)
-- Name: ActorFilm link_Film_ActorFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ActorFilm"
    ADD CONSTRAINT "link_Film_ActorFilm" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") ON DELETE CASCADE;


--
-- TOC entry 4903 (class 2606 OID 25285)
-- Name: CrewMemberFilm link_Film_CrewMemberFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CrewMemberFilm"
    ADD CONSTRAINT "link_Film_CrewMemberFilm" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") ON DELETE CASCADE;


--
-- TOC entry 4897 (class 2606 OID 25086)
-- Name: DirectorFilm link_Film_DirectorFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DirectorFilm"
    ADD CONSTRAINT "link_Film_DirectorFilm" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") ON DELETE CASCADE;


--
-- TOC entry 4894 (class 2606 OID 25130)
-- Name: FilmGenre link_Film_FilmGenre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmGenre"
    ADD CONSTRAINT "link_Film_FilmGenre" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4892 (class 2606 OID 24962)
-- Name: FilmPlace link_Film_FilmPlace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmPlace"
    ADD CONSTRAINT "link_Film_FilmPlace" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4891 (class 2606 OID 24981)
-- Name: FilmRelease link_Film_FilmRelease; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmRelease"
    ADD CONSTRAINT "link_Film_FilmRelease" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4898 (class 2606 OID 25120)
-- Name: ProducerFilm link_Film_ProducerFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProducerFilm"
    ADD CONSTRAINT "link_Film_ProducerFilm" FOREIGN KEY ("filmId") REFERENCES public."Film"("filmId") ON DELETE CASCADE;


--
-- TOC entry 4895 (class 2606 OID 25125)
-- Name: FilmGenre link_Genre_FilmGenre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmGenre"
    ADD CONSTRAINT "link_Genre_FilmGenre" FOREIGN KEY ("genreId") REFERENCES public."Genre"("genreId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4893 (class 2606 OID 24967)
-- Name: FilmPlace link_Place_FilmPlace; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."FilmPlace"
    ADD CONSTRAINT "link_Place_FilmPlace" FOREIGN KEY ("placeId") REFERENCES public."Place"("placeId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4899 (class 2606 OID 25115)
-- Name: ProducerFilm link_Producer_ProducerFilm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProducerFilm"
    ADD CONSTRAINT "link_Producer_ProducerFilm" FOREIGN KEY ("personId") REFERENCES person."Producer"("personId") ON DELETE CASCADE;


--
-- TOC entry 4890 (class 2606 OID 24941)
-- Name: Film link_ProductionCompany_Film; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Film"
    ADD CONSTRAINT "link_ProductionCompany_Film" FOREIGN KEY ("companyId") REFERENCES public."ProductionCompany"("companyId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2025-12-10 00:57:18

--
-- PostgreSQL database dump complete
--

--\unrestrict ezXM9p9Ptfaf5zJg42lwu3gjneCeZAnChrOQrFIbzcsLvFvh9nwvBr1TRqPBTkq