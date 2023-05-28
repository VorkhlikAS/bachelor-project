--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

-- Started on 2023-05-28 21:11:28

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 32785)
-- Name: dev_bot; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dev_bot;

CREATE USER bot_user PASSWORD 'bot_detector';
GRANT USAGE ON SCHEMA dev_bot TO bot_user;

ALTER SCHEMA dev_bot OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 49177)
-- Name: create_load(); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.create_load() RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
    declare
        v_l_id int;
	begin
        perform dev_bot.write_log('INSERT', 'loading data');
	    insert into dev_bot.load(time)
	    values(current_timestamp) returning load_id into v_l_id;
	    return v_l_id;
	end;
$$;


ALTER FUNCTION dev_bot.create_load() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 49217)
-- Name: create_load(integer); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.create_load(p_run_id integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
    declare
        v_l_id int;
	begin
        perform dev_bot.write_log('INSERT', 'loading data');
	    insert into dev_bot.load(time)
	    values(current_timestamp) returning load_id into v_l_id;

        update dev_bot.run
            set last_load_id = v_l_id
        where run_id = p_run_id;
	    return v_l_id;
	end;
$$;


ALTER FUNCTION dev_bot.create_load(p_run_id integer) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 41038)
-- Name: create_run(character varying); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.create_run(p_name character varying) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
    declare
        v_id int;
	begin
        perform dev_bot.write_log('CREATE', 'creating run');
	    insert into dev_bot.run(name, status)
	    values(p_name, 1) returning run_id into v_id;
	    return v_id;
	end;
$$;


ALTER FUNCTION dev_bot.create_run(p_name character varying) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 65577)
-- Name: delete_run(integer); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.delete_run(p_run_id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
	begin
        delete from dev_bot.user_data
	    where run_id = p_run_id;

        delete from dev_bot.run
	    where run_id = p_run_id;

        perform dev_bot.write_log('DELETE', 'deleting run:'||p_run_id||'');
	end;
$$;


ALTER FUNCTION dev_bot.delete_run(p_run_id integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 57381)
-- Name: get_runs(); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.get_runs() RETURNS TABLE(run_id integer, name character varying, status character varying)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
	begin
        return query
	        select t.run_id,
	               t.name,
	               case
	                   when t.status = '1' then
	                        'Расчет создан (1).'::varchar
	                   when t.status = '2' then
	                        'Для расчета загружены учебные данные (2).'::varchar
	                   when t.status = '3' then
	                        'Для расчета обучены модели (3).'::varchar
                       when t.status = '4' then
	                        'Для расчета загружены тестировочные данные (4).'::varchar
	                   when t.status = '5' then
	                        'Результаты расчета готовы к выгрузке (5).'::varchar
	                   else
	                        'Ошибка статуса'::varchar
	                end
	        from dev_bot.run t order by run_id desc;
	end;
$$;


ALTER FUNCTION dev_bot.get_runs() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 73796)
-- Name: get_user_data(integer); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.get_user_data(p_run_id integer) RETURNS TABLE(id character varying, activities character varying, about character varying, books character varying, bdate character varying, career character varying, connections character varying, contacts character varying, city character varying, country character varying, domain character varying, education character varying, exports character varying, followers_count character varying, has_photo character varying, has_mobile character varying, home_town character varying, site character varying, schools character varying, screen_name character varying, status character varying, verified character varying, games character varying, interests character varying, maiden_name character varying, military character varying, movies character varying, music character varying, nickname character varying, occupation character varying, personal character varying, quotes character varying, relation character varying, timezone character varying, tv character varying, universities character varying, fol_cnt character varying, frn_cnt character varying, wll_cnt character varying, pht_cnt character varying, grp_cnt character varying, is_bot character varying)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$ #variable_conflict use_column
    declare
        v_l_load_id int;
	begin
        select last_load_id into v_l_load_id from dev_bot.run where run_id = p_run_id;
		return query
		    select
		        id,
		        case
		            when activities <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when about <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when books <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when bdate <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when career <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when connections <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when contacts <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when city <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when country <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when domain <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when education <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when exports <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when followers_count <> '' then
		                followers_count::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when has_photo <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when has_mobile <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when home_town <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when site <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when schools <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when screen_name <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when status <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when verified <> '' then
		                verified::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when games <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when interests <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when maiden_name <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when military <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when movies <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when music <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when nickname <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when occupation <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when personal <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when quotes <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when relation <> '' then
		                relation::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when timezone <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when tv <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when universities <> '' then
		                '1'::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when fol_cnt <> '' then
		                fol_cnt::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when frn_cnt <> '' then
		                frn_cnt::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when wll_cnt <> '' then
		                wll_cnt::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when pht_cnt <> '' then
		                pht_cnt::varchar
		            else
		                '0'::varchar
                end,
		        case
		            when grp_cnt <> '' then
		                grp_cnt::varchar
		            else
		                '0'::varchar
                end,
		        is_bot::varchar
            from dev_bot.user_data
	        where run_id = p_run_id and load_id = v_l_load_id;
	end;
$$;


ALTER FUNCTION dev_bot.get_user_data(p_run_id integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 57382)
-- Name: set_run_status(integer, integer); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.set_run_status(p_run_id integer, p_status integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
    declare
        v_l_st int;
	begin
        select status::int into v_l_st from dev_bot.run where run_id = p_run_id;
        if v_l_st < p_status - 1 then
            raise exception 'Invalid status!';
        end if;
        update dev_bot.run
        set status = p_status::varchar
        where run_id = p_run_id;

        perform dev_bot.write_log('UPDATE', 'db');
	end;
$$;


ALTER FUNCTION dev_bot.set_run_status(p_run_id integer, p_status integer) OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 32816)
-- Name: write_log(character varying, character varying); Type: FUNCTION; Schema: dev_bot; Owner: postgres
--

CREATE FUNCTION dev_bot.write_log(p_action_code character varying, p_message character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'dev_bot', 'pg_temp'
    AS $$
	begin
		if p_action_code not in ('INSERT', 'UPDATE', 'DELETE', 'CREATE') then
			raise exception 'Invalid action_code value!';
		end if;

		insert into dev_bot.log(time, action_code, description)
		values (CURRENT_TIMESTAMP, p_action_code, p_message);

	end;
$$;


ALTER FUNCTION dev_bot.write_log(p_action_code character varying, p_message character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 32801)
-- Name: dict_action; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.dict_action (
    action_code character varying,
    description character varying
);


ALTER TABLE dev_bot.dict_action OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 40992)
-- Name: dict_status; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.dict_status (
    status_id integer,
    description character varying
);


ALTER TABLE dev_bot.dict_status OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 57370)
-- Name: fin; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.fin (
    user_data_id integer,
    fin_id integer NOT NULL,
    is_bot integer
);


ALTER TABLE dev_bot.fin OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 57369)
-- Name: fin_fin_id_seq; Type: SEQUENCE; Schema: dev_bot; Owner: postgres
--

CREATE SEQUENCE dev_bot.fin_fin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev_bot.fin_fin_id_seq OWNER TO postgres;

--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 219
-- Name: fin_fin_id_seq; Type: SEQUENCE OWNED BY; Schema: dev_bot; Owner: postgres
--

ALTER SEQUENCE dev_bot.fin_fin_id_seq OWNED BY dev_bot.fin.fin_id;


--
-- TOC entry 213 (class 1259 OID 41040)
-- Name: load; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.load (
    load_id integer NOT NULL,
    "time" timestamp without time zone
);


ALTER TABLE dev_bot.load OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 41039)
-- Name: load_load_id_seq; Type: SEQUENCE; Schema: dev_bot; Owner: postgres
--

CREATE SEQUENCE dev_bot.load_load_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev_bot.load_load_id_seq OWNER TO postgres;

--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 212
-- Name: load_load_id_seq; Type: SEQUENCE OWNED BY; Schema: dev_bot; Owner: postgres
--

ALTER SEQUENCE dev_bot.load_load_id_seq OWNED BY dev_bot.load.load_id;


--
-- TOC entry 214 (class 1259 OID 49178)
-- Name: log; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.log (
    "time" timestamp without time zone,
    action_code character varying,
    description character varying,
    CONSTRAINT action_constraint CHECK (((action_code)::text = ANY (ARRAY[('CREATE'::character varying)::text, ('INSERT'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text])))
);


ALTER TABLE dev_bot.log OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 49204)
-- Name: run; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.run (
    run_id integer NOT NULL,
    name character varying,
    status character varying,
    last_load_id integer
);


ALTER TABLE dev_bot.run OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 49203)
-- Name: run_run_id_seq; Type: SEQUENCE; Schema: dev_bot; Owner: postgres
--

CREATE SEQUENCE dev_bot.run_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev_bot.run_run_id_seq OWNER TO postgres;

--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 217
-- Name: run_run_id_seq; Type: SEQUENCE OWNED BY; Schema: dev_bot; Owner: postgres
--

ALTER SEQUENCE dev_bot.run_run_id_seq OWNED BY dev_bot.run.run_id;


--
-- TOC entry 216 (class 1259 OID 49185)
-- Name: user_data; Type: TABLE; Schema: dev_bot; Owner: postgres
--

CREATE TABLE dev_bot.user_data (
    user_data_id integer NOT NULL,
    run_id integer,
    load_id integer,
    id character varying,
    first_name character varying,
    last_name character varying,
    is_closed character varying,
    activities character varying,
    about character varying,
    blacklisted character varying,
    books character varying,
    bdate character varying,
    career character varying,
    connections character varying,
    contacts character varying,
    city character varying,
    country character varying,
    domain character varying,
    education character varying,
    exports character varying,
    followers_count character varying,
    has_photo character varying,
    has_mobile character varying,
    home_town character varying,
    sex character varying,
    site character varying,
    schools character varying,
    screen_name character varying,
    status character varying,
    verified character varying,
    games character varying,
    interests character varying,
    maiden_name character varying,
    military character varying,
    movies character varying,
    music character varying,
    nickname character varying,
    occupation character varying,
    personal character varying,
    quotes character varying,
    relation character varying,
    relatives character varying,
    timezone character varying,
    tv character varying,
    universities character varying,
    is_bot character varying DEFAULT 0,
    fol_cnt character varying DEFAULT 0,
    frn_cnt character varying DEFAULT 0,
    wll_cnt character varying DEFAULT 0,
    pht_cnt character varying DEFAULT 0,
    grp_cnt character varying DEFAULT 0
);


ALTER TABLE dev_bot.user_data OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 49184)
-- Name: user_data_user_data_id_seq; Type: SEQUENCE; Schema: dev_bot; Owner: postgres
--

CREATE SEQUENCE dev_bot.user_data_user_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev_bot.user_data_user_data_id_seq OWNER TO postgres;

--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 215
-- Name: user_data_user_data_id_seq; Type: SEQUENCE OWNED BY; Schema: dev_bot; Owner: postgres
--

ALTER SEQUENCE dev_bot.user_data_user_data_id_seq OWNED BY dev_bot.user_data.user_data_id;


--
-- TOC entry 3210 (class 2604 OID 57373)
-- Name: fin fin_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.fin ALTER COLUMN fin_id SET DEFAULT nextval('dev_bot.fin_fin_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 41043)
-- Name: load load_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.load ALTER COLUMN load_id SET DEFAULT nextval('dev_bot.load_load_id_seq'::regclass);


--
-- TOC entry 3209 (class 2604 OID 49207)
-- Name: run run_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run ALTER COLUMN run_id SET DEFAULT nextval('dev_bot.run_run_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 49188)
-- Name: user_data user_data_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data ALTER COLUMN user_data_id SET DEFAULT nextval('dev_bot.user_data_user_data_id_seq'::regclass);


--
-- TOC entry 3361 (class 0 OID 32801)
-- Dependencies: 210
-- Data for Name: dict_action; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.dict_action (action_code, description) FROM stdin;
INSERT	Добавление данных
UPDATE	Обновление данных
DELETE	Удаление данных
CREATE	Создание данных
\.


--
-- TOC entry 3362 (class 0 OID 40992)
-- Dependencies: 211
-- Data for Name: dict_status; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.dict_status (status_id, description) FROM stdin;
1	Расчет создан
2	Для расчета загружены учебные данные
3	Для расчета обучены модели
4	Для расчета загружены тестировочные данные
5	Тестировочные данные готовы к выгрузке
\.


--
-- TOC entry 3371 (class 0 OID 57370)
-- Dependencies: 220
-- Data for Name: fin; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.fin (user_data_id, fin_id, is_bot) FROM stdin;
\.


--
-- TOC entry 3364 (class 0 OID 41040)
-- Dependencies: 213
-- Data for Name: load; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.load (load_id, "time") FROM stdin;
\.


--
-- TOC entry 3365 (class 0 OID 49178)
-- Dependencies: 214
-- Data for Name: log; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.log ("time", action_code, description) FROM stdin;
\.


--
-- TOC entry 3369 (class 0 OID 49204)
-- Dependencies: 218
-- Data for Name: run; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.run (run_id, name, status, last_load_id) FROM stdin;
\.


--
-- TOC entry 3367 (class 0 OID 49185)
-- Dependencies: 216
-- Data for Name: user_data; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.user_data (user_data_id, run_id, load_id, id, first_name, last_name, is_closed, activities, about, blacklisted, books, bdate, career, connections, contacts, city, country, domain, education, exports, followers_count, has_photo, has_mobile, home_town, sex, site, schools, screen_name, status, verified, games, interests, maiden_name, military, movies, music, nickname, occupation, personal, quotes, relation, relatives, timezone, tv, universities, is_bot, fol_cnt, frn_cnt, wll_cnt, pht_cnt, grp_cnt) FROM stdin;
\.


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 219
-- Name: fin_fin_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.fin_fin_id_seq', 1, false);


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 212
-- Name: load_load_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.load_load_id_seq', 97, true);


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 217
-- Name: run_run_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.run_run_id_seq', 123, true);


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 215
-- Name: user_data_user_data_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.user_data_user_data_id_seq', 4898, true);


--
-- TOC entry 3212 (class 2606 OID 40998)
-- Name: dict_status dict_status_status_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.dict_status
    ADD CONSTRAINT dict_status_status_id_key UNIQUE (status_id);


--
-- TOC entry 3214 (class 2606 OID 41045)
-- Name: load load_load_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.load
    ADD CONSTRAINT load_load_id_key UNIQUE (load_id);


--
-- TOC entry 3218 (class 2606 OID 49211)
-- Name: run run_run_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run
    ADD CONSTRAINT run_run_id_key UNIQUE (run_id);


--
-- TOC entry 3216 (class 2606 OID 49192)
-- Name: user_data user_data_user_data_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data
    ADD CONSTRAINT user_data_user_data_id_key UNIQUE (user_data_id);


--
-- TOC entry 3221 (class 2606 OID 57374)
-- Name: fin fin_user_data_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.fin
    ADD CONSTRAINT fin_user_data_id_fkey FOREIGN KEY (user_data_id) REFERENCES dev_bot.user_data(user_data_id);


--
-- TOC entry 3220 (class 2606 OID 49212)
-- Name: run run_last_load_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run
    ADD CONSTRAINT run_last_load_id_fkey FOREIGN KEY (last_load_id) REFERENCES dev_bot.load(load_id);


--
-- TOC entry 3219 (class 2606 OID 49198)
-- Name: user_data user_data_load_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data
    ADD CONSTRAINT user_data_load_id_fkey FOREIGN KEY (load_id) REFERENCES dev_bot.load(load_id);


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA dev_bot; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA dev_bot TO bot_user;


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 235
-- Name: FUNCTION create_load(); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.create_load() TO bot_user;


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 233
-- Name: FUNCTION create_run(p_name character varying); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.create_run(p_name character varying) TO bot_user;


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 237
-- Name: FUNCTION delete_run(p_run_id integer); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.delete_run(p_run_id integer) TO bot_user;


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 238
-- Name: FUNCTION get_runs(); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.get_runs() TO bot_user;


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 239
-- Name: FUNCTION get_user_data(p_run_id integer); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.get_user_data(p_run_id integer) TO bot_user;


--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 236
-- Name: FUNCTION set_run_status(p_run_id integer, p_status integer); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.set_run_status(p_run_id integer, p_status integer) TO bot_user;


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 224
-- Name: FUNCTION write_log(p_action_code character varying, p_message character varying); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.write_log(p_action_code character varying, p_message character varying) TO bot_user;


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE user_data; Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON TABLE dev_bot.user_data TO bot_user;


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 215
-- Name: SEQUENCE user_data_user_data_id_seq; Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE dev_bot.user_data_user_data_id_seq TO bot_user;


-- Completed on 2023-05-28 21:11:28

--
-- PostgreSQL database dump complete
--

