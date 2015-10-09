--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: travis_test; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE travis_test WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


\connect travis_test

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: delete_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          DELETE FROM logs WHERE id = OLD.id;
          RETURN OLD;
        END;
      $$;


--
-- Name: delete_log_part(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_log_part() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          DELETE FROM log_parts WHERE id = OLD.id;
          RETURN OLD;
        END;
      $$;


--
-- Name: insert_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION insert_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          INSERT INTO logs VALUES (NEW.id, NEW.job_id, NEW.content, NEW.created_at, NEW.updated_at,
            NEW.aggregated_at, NEW.archiving, NEW.archived_at, NEW.archive_verified);
          RETURN NEW;
        END;
      $$;


--
-- Name: insert_log_part(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION insert_log_part() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          INSERT INTO log_parts VALUES (NEW.id, NEW.artifact_id, NEW.content, NEW.number, NEW.final,
            NEW.created_at);
          RETURN NEW;
        END;
      $$;


--
-- Name: update_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE logs
          SET job_id=NEW.job_id, content=NEW.content, created_at=NEW.created_at,
            updated_at=NEW.updated_at, aggregated_at=NEW.aggregated_at, archiving=NEW.archiving,
            archived_at=NEW.archived_at, archive_verified=NEW.archive_verified
          WHERE id = NEW.id;
          RETURN NEW;
        END;
      $$;


--
-- Name: update_log_part(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_log_part() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE logs
          SET log_id=NEW.artifact_id, content=NEW.content, number=NEW.number, created_at=NEW.created_at
          WHERE id = NEW.id;
          RETURN NEW;
        END;
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: annotation_providers; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE annotation_providers (
    id integer NOT NULL,
    name character varying(255),
    api_username character varying(255),
    api_key character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: annotation_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotation_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotation_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotation_providers_id_seq OWNED BY annotation_providers.id;


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE annotations (
    id integer NOT NULL,
    job_id integer NOT NULL,
    url character varying(255),
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    annotation_provider_id integer NOT NULL,
    status character varying(255)
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE branches (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    last_build_id integer,
    name character varying(255) NOT NULL,
    exists_on_github boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE branches_id_seq OWNED BY branches.id;


--
-- Name: broadcasts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE broadcasts (
    id integer NOT NULL,
    recipient_id integer,
    recipient_type character varying(255),
    kind character varying(255),
    message character varying(255),
    expired boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: broadcasts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE broadcasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broadcasts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE broadcasts_id_seq OWNED BY broadcasts.id;


--
-- Name: shared_builds_tasks_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shared_builds_tasks_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE builds (
    id bigint DEFAULT nextval('shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    number character varying(255),
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    config text,
    commit_id integer,
    request_id integer,
    state character varying(255),
    duration integer,
    owner_id integer,
    owner_type character varying(255),
    event_type character varying(255),
    previous_state character varying(255),
    pull_request_title text,
    pull_request_number integer,
    branch character varying(255),
    canceled_at timestamp without time zone,
    cached_matrix_ids integer[],
    received_at timestamp without time zone
);


--
-- Name: builds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE builds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE builds_id_seq OWNED BY builds.id;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE commits (
    id integer NOT NULL,
    repository_id integer,
    commit character varying(255),
    ref character varying(255),
    branch character varying(255),
    message text,
    compare_url character varying(255),
    committed_at timestamp without time zone,
    committer_name character varying(255),
    committer_email character varying(255),
    author_name character varying(255),
    author_email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE commits_id_seq OWNED BY commits.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE emails (
    id integer NOT NULL,
    user_id integer,
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE jobs (
    id bigint DEFAULT nextval('shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    commit_id integer,
    source_id integer,
    source_type character varying(255),
    queue character varying(255),
    type character varying(255),
    state character varying(255),
    number character varying(255),
    config text,
    worker character varying(255),
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tags text,
    allow_failure boolean DEFAULT false,
    owner_id integer,
    owner_type character varying(255),
    result integer,
    queued_at timestamp without time zone,
    canceled_at timestamp without time zone,
    received_at timestamp without time zone
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: log_parts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE log_parts (
    id integer NOT NULL,
    log_id integer NOT NULL,
    content text,
    number integer,
    final boolean,
    created_at timestamp without time zone
);


--
-- Name: log_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_parts_id_seq OWNED BY log_parts.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE logs (
    id integer NOT NULL,
    job_id integer,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    aggregated_at timestamp without time zone,
    archiving boolean,
    archived_at timestamp without time zone,
    archive_verified boolean,
    purged_at timestamp without time zone,
    removed_at timestamp without time zone,
    removed_by integer
);


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logs_id_seq OWNED BY logs.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE memberships (
    id integer NOT NULL,
    organization_id integer,
    user_id integer
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying(255),
    login character varying(255),
    github_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_url character varying(255),
    location character varying(255),
    email character varying(255),
    company character varying(255),
    homepage character varying(255)
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE permissions (
    id integer NOT NULL,
    user_id integer,
    repository_id integer,
    admin boolean DEFAULT false,
    push boolean DEFAULT false,
    pull boolean DEFAULT false
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE repositories (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invalidated_at timestamp without time zone,
    last_build_id integer,
    last_build_number character varying(255),
    last_build_started_at timestamp without time zone,
    last_build_finished_at timestamp without time zone,
    owner_name character varying(255),
    owner_email text,
    active boolean,
    description text,
    last_build_duration integer,
    owner_id integer,
    owner_type character varying(255),
    private boolean DEFAULT false,
    last_build_state character varying(255),
    github_id integer,
    default_branch character varying(255),
    github_language character varying(255),
    settings json,
    next_build_number integer
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repositories_id_seq OWNED BY repositories.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE requests (
    id integer NOT NULL,
    repository_id integer,
    commit_id integer,
    state character varying(255),
    source character varying(255),
    payload text,
    token character varying(255),
    config text,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    event_type character varying(255),
    comments_url character varying(255),
    base_commit character varying(255),
    head_commit character varying(255),
    owner_id integer,
    owner_type character varying(255),
    result character varying(255),
    message character varying(255)
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE requests_id_seq OWNED BY requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: ssl_keys; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE ssl_keys (
    id integer NOT NULL,
    repository_id integer,
    public_key text,
    private_key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ssl_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ssl_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ssl_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ssl_keys_id_seq OWNED BY ssl_keys.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE tokens (
    id integer NOT NULL,
    user_id integer,
    token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tokens_id_seq OWNED BY tokens.id;


--
-- Name: urls; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE urls (
    id integer NOT NULL,
    url character varying(255),
    code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE urls_id_seq OWNED BY urls.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    login character varying(255),
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_admin boolean DEFAULT false,
    github_id integer,
    github_oauth_token character varying(255),
    gravatar_id character varying(255),
    locale character varying(255),
    is_syncing boolean,
    synced_at timestamp without time zone,
    github_scopes text,
    education boolean
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotation_providers ALTER COLUMN id SET DEFAULT nextval('annotation_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches ALTER COLUMN id SET DEFAULT nextval('branches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY broadcasts ALTER COLUMN id SET DEFAULT nextval('broadcasts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits ALTER COLUMN id SET DEFAULT nextval('commits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_parts ALTER COLUMN id SET DEFAULT nextval('log_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories ALTER COLUMN id SET DEFAULT nextval('repositories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests ALTER COLUMN id SET DEFAULT nextval('requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ssl_keys ALTER COLUMN id SET DEFAULT nextval('ssl_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens ALTER COLUMN id SET DEFAULT nextval('tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY urls ALTER COLUMN id SET DEFAULT nextval('urls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: annotation_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY annotation_providers
    ADD CONSTRAINT annotation_providers_pkey PRIMARY KEY (id);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: broadcasts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY broadcasts
    ADD CONSTRAINT broadcasts_pkey PRIMARY KEY (id);


--
-- Name: builds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (id);


--
-- Name: commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: log_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY log_parts
    ADD CONSTRAINT log_parts_pkey PRIMARY KEY (id);


--
-- Name: logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: ssl_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY ssl_keys
    ADD CONSTRAINT ssl_keys_pkey PRIMARY KEY (id);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY urls
    ADD CONSTRAINT urls_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_branches_on_repository_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_branches_on_repository_id_and_name ON branches USING btree (repository_id, name);


--
-- Name: index_builds_on_id_repository_id_and_event_type_desc; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_builds_on_id_repository_id_and_event_type_desc ON builds USING btree (id DESC, repository_id, event_type);


--
-- Name: index_builds_on_repository_id_and_event_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_builds_on_repository_id_and_event_type ON builds USING btree (repository_id, event_type);


--
-- Name: index_builds_on_repository_id_and_event_type_and_state_and_bran; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_builds_on_repository_id_and_event_type_and_state_and_bran ON builds USING btree (repository_id, event_type, state, branch);


--
-- Name: index_builds_on_repository_id_and_state; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_builds_on_repository_id_and_state ON builds USING btree (repository_id, state);


--
-- Name: index_builds_on_request_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_builds_on_request_id ON builds USING btree (request_id);


--
-- Name: index_commits_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_commits_on_repository_id ON commits USING btree (repository_id);


--
-- Name: index_emails_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_emails_on_email ON emails USING btree (email);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_emails_on_user_id ON emails USING btree (user_id);


--
-- Name: index_jobs_on_owner_id_and_owner_type_and_state; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_jobs_on_owner_id_and_owner_type_and_state ON jobs USING btree (owner_id, owner_type, state);


--
-- Name: index_jobs_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_jobs_on_repository_id ON jobs USING btree (repository_id);


--
-- Name: index_jobs_on_state_owner_type_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_jobs_on_state_owner_type_owner_id ON jobs USING btree (state, owner_id, owner_type);


--
-- Name: index_jobs_on_type_and_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_jobs_on_type_and_owner_id_and_owner_type ON jobs USING btree (type, source_id, source_type);


--
-- Name: index_log_parts_on_log_id_and_number; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_log_parts_on_log_id_and_number ON log_parts USING btree (log_id, number);


--
-- Name: index_logs_on_archive_verified; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_logs_on_archive_verified ON logs USING btree (archive_verified);


--
-- Name: index_logs_on_archived_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_logs_on_archived_at ON logs USING btree (archived_at);


--
-- Name: index_logs_on_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_logs_on_job_id ON logs USING btree (job_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_memberships_on_user_id ON memberships USING btree (user_id);


--
-- Name: index_organizations_on_github_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_organizations_on_github_id ON organizations USING btree (github_id);


--
-- Name: index_permissions_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_permissions_on_repository_id ON permissions USING btree (repository_id);


--
-- Name: index_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_permissions_on_user_id ON permissions USING btree (user_id);


--
-- Name: index_repositories_on_github_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_repositories_on_github_id ON repositories USING btree (github_id);


--
-- Name: index_repositories_on_last_build_started_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_repositories_on_last_build_started_at ON repositories USING btree (last_build_started_at);


--
-- Name: index_repositories_on_owner_name_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_repositories_on_owner_name_and_name ON repositories USING btree (owner_name, name);


--
-- Name: index_requests_on_commit_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_requests_on_commit_id ON requests USING btree (commit_id);


--
-- Name: index_requests_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_requests_on_created_at ON requests USING btree (created_at);


--
-- Name: index_requests_on_head_commit; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_requests_on_head_commit ON requests USING btree (head_commit);


--
-- Name: index_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_requests_on_repository_id ON requests USING btree (repository_id);


--
-- Name: index_ssl_key_on_repository_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_ssl_key_on_repository_id ON ssl_keys USING btree (repository_id);


--
-- Name: index_users_on_github_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_github_id ON users USING btree (github_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: log_parts_log_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_parts
    ADD CONSTRAINT log_parts_log_id_fk FOREIGN KEY (log_id) REFERENCES logs(id);


--
-- PostgreSQL database dump complete
--


