--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

-- Started on 2023-05-25 23:26:58

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
-- TOC entry 3383 (class 0 OID 0)
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
-- TOC entry 3384 (class 0 OID 0)
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
-- TOC entry 3385 (class 0 OID 0)
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
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 215
-- Name: user_data_user_data_id_seq; Type: SEQUENCE OWNED BY; Schema: dev_bot; Owner: postgres
--

ALTER SEQUENCE dev_bot.user_data_user_data_id_seq OWNED BY dev_bot.user_data.user_data_id;


--
-- TOC entry 3209 (class 2604 OID 57373)
-- Name: fin fin_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.fin ALTER COLUMN fin_id SET DEFAULT nextval('dev_bot.fin_fin_id_seq'::regclass);


--
-- TOC entry 3199 (class 2604 OID 41043)
-- Name: load load_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.load ALTER COLUMN load_id SET DEFAULT nextval('dev_bot.load_load_id_seq'::regclass);


--
-- TOC entry 3208 (class 2604 OID 49207)
-- Name: run run_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run ALTER COLUMN run_id SET DEFAULT nextval('dev_bot.run_run_id_seq'::regclass);


--
-- TOC entry 3201 (class 2604 OID 49188)
-- Name: user_data user_data_id; Type: DEFAULT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data ALTER COLUMN user_data_id SET DEFAULT nextval('dev_bot.user_data_user_data_id_seq'::regclass);


--
-- TOC entry 3360 (class 0 OID 32801)
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
-- TOC entry 3361 (class 0 OID 40992)
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
-- TOC entry 3370 (class 0 OID 57370)
-- Dependencies: 220
-- Data for Name: fin; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.fin (user_data_id, fin_id, is_bot) FROM stdin;
\.


--
-- TOC entry 3363 (class 0 OID 41040)
-- Dependencies: 213
-- Data for Name: load; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.load (load_id, "time") FROM stdin;
\.


--
-- TOC entry 3364 (class 0 OID 49178)
-- Dependencies: 214
-- Data for Name: log; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.log ("time", action_code, description) FROM stdin;
2023-05-06 03:08:33.458597	INSERT	python_test
2023-05-06 03:08:33.458597	CREATE	creating run
2023-05-06 03:08:33.458597	INSERT	loading data
2023-05-06 03:08:39.619315	INSERT	python_test
2023-05-06 03:08:39.619315	CREATE	creating run
2023-05-06 03:08:39.619315	INSERT	loading data
2023-05-06 03:12:35.269991	INSERT	python_test
2023-05-06 03:12:35.269991	CREATE	creating run
2023-05-06 03:12:35.269991	INSERT	loading data
2023-05-06 03:13:04.716616	INSERT	python_test
2023-05-06 03:13:04.716616	CREATE	creating run
2023-05-06 03:13:04.716616	INSERT	loading data
2023-05-08 21:12:40.533226	INSERT	python_test
2023-05-08 21:12:40.533226	CREATE	creating run
2023-05-08 21:12:40.533226	INSERT	loading data
2023-05-08 22:05:59.014274	INSERT	python_test
2023-05-08 22:05:59.014274	CREATE	creating run
2023-05-08 22:05:59.014274	INSERT	loading data
2023-05-08 22:10:13.385818	INSERT	python_test
2023-05-08 22:10:13.385818	CREATE	creating run
2023-05-08 22:10:13.385818	INSERT	loading data
2023-05-08 22:13:10.056116	INSERT	python_test
2023-05-08 22:13:10.056116	CREATE	creating run
2023-05-08 22:13:10.056116	INSERT	loading data
2023-05-08 22:14:02.966824	INSERT	python_test
2023-05-08 22:14:02.966824	CREATE	creating run
2023-05-08 22:14:02.966824	INSERT	loading data
2023-05-08 22:19:05.508739	INSERT	python_test
2023-05-08 22:19:05.508739	CREATE	creating run
2023-05-08 22:19:05.508739	INSERT	loading data
2023-05-08 22:37:55.592804	INSERT	python_test
2023-05-08 22:37:55.592804	CREATE	creating run
2023-05-08 22:37:55.592804	INSERT	loading data
2023-05-14 17:34:16.303212	CREATE	creating run
2023-05-14 17:34:36.272308	CREATE	creating run
2023-05-14 17:36:16.224265	CREATE	creating run
2023-05-14 19:22:23.277329	CREATE	creating run
2023-05-14 19:26:38.908534	CREATE	creating run
2023-05-14 19:42:12.467371	CREATE	creating run
2023-05-14 20:44:44.133771	CREATE	creating run
2023-05-14 20:53:24.212456	CREATE	creating run
2023-05-14 21:13:41.366851	UPDATE	db
2023-05-14 21:13:42.09285	INSERT	loading data
2023-05-14 21:13:42.474704	INSERT	server: user_data, 17:14
2023-05-14 21:13:42.767243	DELETE	server: deleting source file
2023-05-14 22:33:21.024386	CREATE	creating run
2023-05-14 22:34:01.201747	UPDATE	db
2023-05-14 22:34:01.687222	INSERT	loading data
2023-05-14 22:34:02.101009	INSERT	server: user_data, 18:15
2023-05-14 22:34:02.43895	DELETE	server: deleting source file
2023-05-14 23:41:51.465648	UPDATE	db
2023-05-14 23:42:02.110717	CREATE	server: creating svm
2023-05-15 00:03:24.464086	UPDATE	db
2023-05-15 00:03:26.680577	INSERT	server: loading test
2023-05-15 00:03:29.845007	UPDATE	db
2023-05-15 00:03:32.913512	UPDATE	server: running calculations
2023-05-15 00:26:21.939973	CREATE	creating run
2023-05-15 00:26:54.969099	UPDATE	db
2023-05-15 00:26:55.08111	INSERT	loading data
2023-05-15 00:26:55.404229	INSERT	server: user_data, 19:16
2023-05-15 00:26:55.631196	DELETE	server: deleting source file
2023-05-15 00:27:08.279835	UPDATE	db
2023-05-15 00:27:18.346836	CREATE	server: creating forest
2023-05-15 00:27:45.48316	UPDATE	db
2023-05-15 00:27:47.904583	INSERT	server: loading test
2023-05-15 00:27:49.991803	UPDATE	db
2023-05-15 00:27:53.087751	UPDATE	server: running calculations
2023-05-15 00:57:32.014792	CREATE	creating run
2023-05-15 00:57:59.874452	UPDATE	db
2023-05-15 00:58:00.081937	INSERT	loading data
2023-05-15 00:58:00.291348	INSERT	server: user_data, 20:17
2023-05-15 00:58:00.47501	DELETE	server: deleting source file
2023-05-15 00:58:12.106566	UPDATE	db
2023-05-15 00:58:22.279194	CREATE	server: creating tree
2023-05-15 00:58:28.98728	UPDATE	db
2023-05-15 00:58:31.172783	INSERT	server: loading test
2023-05-15 00:58:33.97059	UPDATE	db
2023-05-15 00:58:37.168505	UPDATE	server: running calculations
2023-05-15 01:04:08.440091	CREATE	creating run
2023-05-15 01:04:23.480238	UPDATE	db
2023-05-15 01:04:23.559832	INSERT	loading data
2023-05-15 01:04:23.715522	INSERT	server: user_data, 21:18
2023-05-15 01:04:23.809617	DELETE	server: deleting source file
2023-05-15 01:04:29.771251	UPDATE	db
2023-05-15 01:04:39.859535	CREATE	server: creating svm
2023-05-15 01:04:48.804591	UPDATE	db
2023-05-15 01:04:50.90409	INSERT	server: loading test
2023-05-15 01:04:55.712746	UPDATE	db
2023-05-15 01:04:58.869683	UPDATE	server: running calculations
2023-05-16 02:35:38.599615	CREATE	creating run
2023-05-16 02:36:03.234897	CREATE	creating run
2023-05-16 03:04:06.540608	CREATE	creating run
2023-05-16 23:28:16.920736	UPDATE	db
2023-05-16 23:28:23.233122	INSERT	loading data
2023-05-16 23:28:26.300744	INSERT	server: user_data, 6:19
2023-05-16 23:28:27.523598	DELETE	server: deleting source file
2023-05-20 17:04:41.948886	CREATE	creating run
2023-05-20 17:06:59.6671	CREATE	creating run
2023-05-20 19:46:05.566206	CREATE	creating run
2023-05-20 19:49:42.081679	UPDATE	db
2023-05-20 19:49:42.456919	INSERT	loading data
2023-05-20 19:49:42.954498	INSERT	server: user_data, 27:20
2023-05-20 19:49:43.306203	DELETE	server: deleting source file
2023-05-20 19:49:58.150912	UPDATE	db
2023-05-20 19:50:08.220998	CREATE	server: creating svm
2023-05-20 19:50:16.98397	UPDATE	db
2023-05-20 19:50:19.060569	INSERT	server: loading test
2023-05-20 19:50:22.822929	UPDATE	db
2023-05-20 19:50:25.915733	UPDATE	server: running calculations
2023-05-23 23:57:29.376867	CREATE	creating run
2023-05-25 00:08:40.941912	CREATE	creating run
2023-05-25 00:14:49.891132	UPDATE	db
2023-05-25 00:14:50.217018	INSERT	loading data
2023-05-25 00:14:50.385159	INSERT	server: user_data, 29:21
2023-05-25 00:17:35.03563	CREATE	creating run
2023-05-25 00:17:52.79377	UPDATE	db
2023-05-25 00:17:52.849011	INSERT	loading data
2023-05-25 00:17:53.070691	INSERT	server: user_data, 30:22
2023-05-25 00:17:53.16874	DELETE	server: deleting source file
2023-05-25 00:20:48.62062	CREATE	creating run
2023-05-25 00:21:08.962169	UPDATE	db
2023-05-25 00:21:09.021592	INSERT	loading data
2023-05-25 00:21:09.253959	INSERT	server: user_data, 31:23
2023-05-25 00:21:09.342018	DELETE	server: deleting source file
2023-05-25 01:01:49.033864	DELETE	server: run, 1
2023-05-25 01:03:08.86853	DELETE	server: run, 1
2023-05-25 01:03:08.874725	DELETE	deleting run:1
2023-05-25 01:03:12.548553	DELETE	server: run, 2
2023-05-25 01:03:12.555225	DELETE	deleting run:2
2023-05-25 01:03:18.478191	DELETE	server: run, 3
2023-05-25 01:03:18.48406	DELETE	deleting run:3
2023-05-25 01:03:21.198908	DELETE	server: run, 4
2023-05-25 01:03:21.206015	DELETE	deleting run:4
2023-05-25 01:03:24.119022	DELETE	server: run, 5
2023-05-25 01:03:24.127355	DELETE	deleting run:5
2023-05-25 01:04:17.871944	DELETE	server: run, 6
2023-05-25 01:04:17.921766	DELETE	deleting run:6
2023-05-25 01:04:20.669324	DELETE	server: run, 8
2023-05-25 01:04:20.67576	DELETE	deleting run:8
2023-05-25 01:04:22.977006	DELETE	server: run, 7
2023-05-25 01:04:22.985773	DELETE	deleting run:7
2023-05-25 01:04:25.119122	DELETE	server: run, 9
2023-05-25 01:04:25.125305	DELETE	deleting run:9
2023-05-25 01:04:28.020096	DELETE	server: run, 10
2023-05-25 01:04:28.026604	DELETE	deleting run:10
2023-05-25 01:04:30.48391	DELETE	server: run, 11
2023-05-25 01:04:30.490764	DELETE	deleting run:11
2023-05-25 01:04:33.800379	DELETE	server: run, 12
2023-05-25 01:04:33.80645	DELETE	deleting run:12
2023-05-25 01:04:36.147966	DELETE	server: run, 13
2023-05-25 01:04:36.154339	DELETE	deleting run:13
2023-05-25 01:04:38.838042	DELETE	server: run, 14
2023-05-25 01:04:38.843492	DELETE	deleting run:14
2023-05-25 01:04:42.028952	DELETE	server: run, 15
2023-05-25 01:04:42.040642	DELETE	deleting run:15
2023-05-25 01:04:45.033468	DELETE	server: run, 16
2023-05-25 01:04:45.039866	DELETE	deleting run:16
2023-05-25 01:04:47.142062	DELETE	server: run, 17
2023-05-25 01:04:47.149398	DELETE	deleting run:17
2023-05-25 01:04:49.367094	DELETE	server: run, 18
2023-05-25 01:04:49.373872	DELETE	deleting run:18
2023-05-25 01:04:51.7553	DELETE	server: run, 19
2023-05-25 01:04:51.764158	DELETE	deleting run:19
2023-05-25 01:04:54.021929	DELETE	server: run, 20
2023-05-25 01:04:54.029539	DELETE	deleting run:20
2023-05-25 01:04:56.920302	DELETE	server: run, 21
2023-05-25 01:04:56.929792	DELETE	deleting run:21
2023-05-25 01:04:59.910851	DELETE	server: run, 22
2023-05-25 01:04:59.91728	DELETE	deleting run:22
2023-05-25 01:05:26.7757	CREATE	creating run
2023-05-25 01:05:28.329908	CREATE	creating run
2023-05-25 01:05:29.531152	CREATE	creating run
2023-05-25 01:05:30.646919	CREATE	creating run
2023-05-25 01:05:31.771153	CREATE	creating run
2023-05-25 01:05:36.151186	DELETE	server: run, 36
2023-05-25 01:05:36.311074	DELETE	deleting run:36
2023-05-25 01:05:38.169466	DELETE	server: run, 35
2023-05-25 01:05:38.17793	DELETE	deleting run:35
2023-05-25 01:05:39.686486	DELETE	server: run, 34
2023-05-25 01:05:39.695752	DELETE	deleting run:34
2023-05-25 01:05:41.355664	DELETE	server: run, 33
2023-05-25 01:05:41.490172	DELETE	deleting run:33
2023-05-25 01:07:15.342021	DELETE	server: run, 30
2023-05-25 01:07:15.350064	DELETE	deleting run:30
2023-05-25 01:07:17.709066	DELETE	server: run, 23
2023-05-25 01:07:17.71555	DELETE	deleting run:23
2023-05-25 01:07:19.112929	DELETE	server: run, 27
2023-05-25 01:07:19.123168	DELETE	deleting run:27
2023-05-25 01:08:54.870414	CREATE	creating run
2023-05-25 01:11:48.044393	CREATE	creating run
2023-05-25 01:11:49.347675	CREATE	creating run
2023-05-25 01:11:50.427491	CREATE	creating run
2023-05-25 01:11:51.395481	CREATE	creating run
2023-05-25 01:11:52.294237	CREATE	creating run
2023-05-25 01:11:53.12857	CREATE	creating run
2023-05-25 01:11:53.942843	CREATE	creating run
2023-05-25 01:11:55.683982	DELETE	server: run, 43
2023-05-25 01:11:55.696761	DELETE	deleting run:43
2023-05-25 01:11:56.867444	DELETE	server: run, 42
2023-05-25 01:11:56.877407	DELETE	deleting run:42
2023-05-25 01:11:58.393339	DELETE	server: run, 40
2023-05-25 01:11:58.400628	DELETE	deleting run:40
2023-05-25 01:12:00.180232	DELETE	server: run, 39
2023-05-25 01:12:00.189418	DELETE	deleting run:39
2023-05-25 01:13:25.826053	CREATE	creating run
2023-05-25 01:14:14.915181	DELETE	server: run, 45
2023-05-25 01:14:14.922947	DELETE	deleting run:45
2023-05-25 01:14:16.759569	DELETE	server: run, 44
2023-05-25 01:14:17.559239	DELETE	deleting run:44
2023-05-25 01:14:22.312988	DELETE	server: run, 41
2023-05-25 01:14:22.64593	DELETE	deleting run:41
2023-05-25 01:14:23.987897	DELETE	server: run, 38
2023-05-25 01:14:24.200243	DELETE	deleting run:38
2023-05-25 01:14:25.743327	DELETE	server: run, 37
2023-05-25 01:14:25.749888	DELETE	deleting run:37
2023-05-25 01:14:28.250702	DELETE	server: run, 32
2023-05-25 01:14:28.262607	DELETE	deleting run:32
2023-05-25 01:14:29.806386	DELETE	server: run, 31
2023-05-25 01:14:29.814354	DELETE	deleting run:31
2023-05-25 01:14:31.077698	DELETE	server: run, 29
2023-05-25 01:14:31.118609	DELETE	deleting run:29
2023-05-25 01:14:32.459869	DELETE	server: run, 28
2023-05-25 01:14:32.467598	DELETE	deleting run:28
2023-05-25 01:14:33.942997	DELETE	server: run, 26
2023-05-25 01:14:33.949909	DELETE	deleting run:26
2023-05-25 01:14:35.977428	DELETE	server: run, 25
2023-05-25 01:14:35.984103	DELETE	deleting run:25
2023-05-25 01:14:37.46507	DELETE	server: run, 24
2023-05-25 01:14:37.471495	DELETE	deleting run:24
2023-05-25 01:14:58.279572	CREATE	creating run
2023-05-25 01:15:15.208591	CREATE	creating run
2023-05-25 01:18:00.860191	CREATE	creating run
2023-05-25 01:19:08.621152	DELETE	server: run, 47
2023-05-25 01:19:08.637622	DELETE	deleting run:47
2023-05-25 01:19:37.053364	UPDATE	db
2023-05-25 01:19:37.116837	INSERT	loading data
2023-05-25 01:19:37.239604	INSERT	server: user_data, 48:24
2023-05-25 01:19:37.460334	DELETE	server: deleting source file
2023-05-25 01:34:40.700093	UPDATE	db
2023-05-25 01:34:40.769235	INSERT	loading data
2023-05-25 01:34:40.999572	INSERT	server: user_data, 46:25
2023-05-25 01:34:41.076847	DELETE	server: deleting source file
2023-05-25 01:44:24.153385	CREATE	creating run
2023-05-25 01:44:41.571479	UPDATE	db
2023-05-25 01:44:41.64331	INSERT	loading data
2023-05-25 01:44:41.767125	INSERT	server: user_data, 49:26
2023-05-25 01:44:41.941064	DELETE	server: deleting source file
2023-05-25 09:45:18.475719	CREATE	creating run
2023-05-25 09:45:51.595568	UPDATE	db
2023-05-25 09:45:51.710256	INSERT	loading data
2023-05-25 09:45:51.953844	INSERT	server: user_data, 50:27
2023-05-25 09:45:52.076625	DELETE	server: deleting source file
2023-05-25 10:00:24.206947	CREATE	creating run
2023-05-25 10:00:54.70219	UPDATE	db
2023-05-25 10:00:54.791257	INSERT	loading data
2023-05-25 10:00:55.000955	INSERT	server: user_data, 51:28
2023-05-25 10:00:55.145593	DELETE	server: deleting source file
2023-05-25 10:02:23.217635	CREATE	creating run
2023-05-25 10:02:26.139775	DELETE	server: run, 46
2023-05-25 10:02:26.150212	DELETE	deleting run:46
2023-05-25 10:02:27.442707	DELETE	server: run, 48
2023-05-25 10:02:27.512075	DELETE	deleting run:48
2023-05-25 10:02:28.596717	DELETE	server: run, 49
2023-05-25 10:02:28.604052	DELETE	deleting run:49
2023-05-25 10:02:29.715098	DELETE	server: run, 50
2023-05-25 10:02:29.721811	DELETE	deleting run:50
2023-05-25 10:02:30.786073	DELETE	server: run, 51
2023-05-25 10:02:30.791817	DELETE	deleting run:51
2023-05-25 10:03:00.334323	UPDATE	db
2023-05-25 10:03:00.453513	INSERT	loading data
2023-05-25 10:03:00.701289	INSERT	server: user_data, 52:29
2023-05-25 10:03:00.849426	DELETE	server: deleting source file
2023-05-25 10:04:09.452536	UPDATE	db
2023-05-25 10:04:19.528746	CREATE	server: creating forest
2023-05-25 10:04:55.592561	DELETE	server: run, 52
2023-05-25 10:04:55.60116	DELETE	deleting run:52
\.


--
-- TOC entry 3368 (class 0 OID 49204)
-- Dependencies: 218
-- Data for Name: run; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.run (run_id, name, status, last_load_id) FROM stdin;
\.


--
-- TOC entry 3366 (class 0 OID 49185)
-- Dependencies: 216
-- Data for Name: user_data; Type: TABLE DATA; Schema: dev_bot; Owner: postgres
--

COPY dev_bot.user_data (user_data_id, run_id, load_id, id, first_name, last_name, is_closed, activities, about, blacklisted, books, bdate, career, connections, contacts, city, country, domain, education, exports, followers_count, has_photo, has_mobile, home_town, sex, site, schools, screen_name, status, verified, games, interests, maiden_name, military, movies, music, nickname, occupation, personal, quotes, relation, relatives, timezone, tv, universities, is_bot, fol_cnt, frn_cnt, wll_cnt, pht_cnt, grp_cnt) FROM stdin;
\.


--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 219
-- Name: fin_fin_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.fin_fin_id_seq', 1, false);


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 212
-- Name: load_load_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.load_load_id_seq', 29, true);


--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 217
-- Name: run_run_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.run_run_id_seq', 52, true);


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 215
-- Name: user_data_user_data_id_seq; Type: SEQUENCE SET; Schema: dev_bot; Owner: postgres
--

SELECT pg_catalog.setval('dev_bot.user_data_user_data_id_seq', 373, true);


--
-- TOC entry 3211 (class 2606 OID 40998)
-- Name: dict_status dict_status_status_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.dict_status
    ADD CONSTRAINT dict_status_status_id_key UNIQUE (status_id);


--
-- TOC entry 3213 (class 2606 OID 41045)
-- Name: load load_load_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.load
    ADD CONSTRAINT load_load_id_key UNIQUE (load_id);


--
-- TOC entry 3217 (class 2606 OID 49211)
-- Name: run run_run_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run
    ADD CONSTRAINT run_run_id_key UNIQUE (run_id);


--
-- TOC entry 3215 (class 2606 OID 49192)
-- Name: user_data user_data_user_data_id_key; Type: CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data
    ADD CONSTRAINT user_data_user_data_id_key UNIQUE (user_data_id);


--
-- TOC entry 3220 (class 2606 OID 57374)
-- Name: fin fin_user_data_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.fin
    ADD CONSTRAINT fin_user_data_id_fkey FOREIGN KEY (user_data_id) REFERENCES dev_bot.user_data(user_data_id);


--
-- TOC entry 3219 (class 2606 OID 49212)
-- Name: run run_last_load_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.run
    ADD CONSTRAINT run_last_load_id_fkey FOREIGN KEY (last_load_id) REFERENCES dev_bot.load(load_id);


--
-- TOC entry 3218 (class 2606 OID 49198)
-- Name: user_data user_data_load_id_fkey; Type: FK CONSTRAINT; Schema: dev_bot; Owner: postgres
--

ALTER TABLE ONLY dev_bot.user_data
    ADD CONSTRAINT user_data_load_id_fkey FOREIGN KEY (load_id) REFERENCES dev_bot.load(load_id);


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA dev_bot; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA dev_bot TO bot_user;


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 235
-- Name: FUNCTION create_load(); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.create_load() TO bot_user;


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 233
-- Name: FUNCTION create_run(p_name character varying); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.create_run(p_name character varying) TO bot_user;


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 237
-- Name: FUNCTION delete_run(p_run_id integer); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.delete_run(p_run_id integer) TO bot_user;


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 238
-- Name: FUNCTION get_runs(); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.get_runs() TO bot_user;


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 236
-- Name: FUNCTION set_run_status(p_run_id integer, p_status integer); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.set_run_status(p_run_id integer, p_status integer) TO bot_user;


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 224
-- Name: FUNCTION write_log(p_action_code character varying, p_message character varying); Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON FUNCTION dev_bot.write_log(p_action_code character varying, p_message character varying) TO bot_user;


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE user_data; Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT ALL ON TABLE dev_bot.user_data TO bot_user;


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 215
-- Name: SEQUENCE user_data_user_data_id_seq; Type: ACL; Schema: dev_bot; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE dev_bot.user_data_user_data_id_seq TO bot_user;


-- Completed on 2023-05-25 23:26:58

--
-- PostgreSQL database dump complete
--

