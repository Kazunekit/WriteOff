------
-- Schema for WriteOff.pm's database
-- Author: Cameron Thornton <cthor@cpan.org>
------

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS login_attempts;
DROP TABLE IF EXISTS bans;
DROP TABLE IF EXISTS votes;
DROP TABLE IF EXISTS vote_records;
DROP TABLE IF EXISTS heats;
DROP TABLE IF EXISTS prompts;
DROP TABLE IF EXISTS image_story;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS storys;
DROP TABLE IF EXISTS user_event;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS user_role;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- User tables
CREATE TABLE users (
	id          INTEGER PRIMARY KEY,
	username    TEXT UNIQUE,
	password    TEXT,
	email       TEXT UNIQUE,
	timezone    TEXT DEFAULT 'UTC',
	ip          TEXT,
	verified    INTEGER DEFAULT 0,
	mailme      INTEGER DEFAULT 0,
	token       TEXT,
	created     TIMESTAMP
);

CREATE TABLE roles (
	id   INTEGER PRIMARY KEY,
	role TEXT
);

INSERT INTO roles VALUES (1, 'admin');
INSERT INTO roles VALUES (2, 'user');

CREATE TABLE user_role (
	user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
	role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
	PRIMARY KEY (user_id, role_id)
);

CREATE TABLE bans (
	id       INTEGER PRIMARY KEY,
	ip       TEXT,
	reason   TEXT,
	expires  TIMESTAMP,
	created  TIMESTAMP
);

CREATE TABLE login_attempts (
	id       INTEGER PRIMARY KEY,
	ip       TEXT,
	created  TIMESTAMP
);

-- Event tables
CREATE TABLE events (
	id              INTEGER PRIMARY KEY,
	prompt          TEXT DEFAULT 'TBD',
	title           TEXT,
	blurb           TEXT,
	wc_min          INTEGER,
	wc_max          INTEGER,
	rule_set        INTEGER,
	"start"         TIMESTAMP,
	prompt_voting   TIMESTAMP,
	art             TIMESTAMP,
	art_end         TIMESTAMP,
	fic             TIMESTAMP,
	fic_end         TIMESTAMP,
	prelim          TIMESTAMP,
	"public"        TIMESTAMP,
	"private"       TIMESTAMP,
	"end"           TIMESTAMP,
	created         TIMESTAMP
);

CREATE TABLE user_event (
	user_id   INTEGER REFERENCES users(id)  ON DELETE CASCADE,
	event_id  INTEGER REFERENCES events(id) ON DELETE CASCADE,
	role      TEXT,
	PRIMARY KEY (user_id, event_id, role)
);

CREATE TABLE schedules (
	id      INTEGER PRIMARY KEY,
	action  TEXT,
	"at"    TIMESTAMP,
	args    TEXT
);

CREATE TABLE heats (
	id       INTEGER PRIMARY KEY,
	"left"   INTEGER REFERENCES prompts(id) ON DELETE CASCADE,
	"right"  INTEGER REFERENCES prompts(id) ON DELETE CASCADE,
	created  TIMESTAMP
);

-- Resource tables
CREATE TABLE prompts (
	id        INTEGER PRIMARY KEY,
	event_id  INTEGER REFERENCES events(id) ON DELETE CASCADE,
	user_id   INTEGER REFERENCES users(id) ON DELETE CASCADE,
	ip        TEXT,
	contents  TEXT,
	rating    REAL,
	created   TIMESTAMP
);

CREATE TABLE storys (
	id         INTEGER PRIMARY KEY,
	event_id   INTEGER REFERENCES events(id) ON DELETE CASCADE,
	user_id    INTEGER REFERENCES users(id) ON DELETE CASCADE,
	ip         TEXT,
	title      TEXT UNIQUE,
	author     TEXT,
	website    TEXT,
	contents   TEXT,
	wordcount  INTEGER,
	seed       REAL,
	created    TIMESTAMP,
	updated    TIMESTAMP
);

CREATE TABLE images (
	id        INTEGER PRIMARY KEY,
	event_id  INTEGER REFERENCES events(id) ON DELETE CASCADE,
	user_id   INTEGER REFERENCES users(id) ON DELETE CASCADE,
	ip        TEXT,
	title     TEXT UNIQUE,
	artist    TEXT,
	website   TEXT,
	contents  BLOB,
	thumb     BLOB,
	filesize  INTEGER,
	mimetype  TEXT,
	seed      REAL,
	created   TIMESTAMP
);

CREATE TABLE image_story (
	image_id  INTEGER REFERENCES images(id) ON DELETE CASCADE,
	story_id  INTEGER REFERENCES storys(id) ON DELETE CASCADE,
	PRIMARY KEY (image_id, story_id)
);

CREATE TABLE vote_records (
	id        INTEGER PRIMARY KEY,
	event_id  INTEGER REFERENCES events(id) ON DELETE CASCADE,
	user_id   INTEGER REFERENCES users(id) ON DELETE SET NULL,
	ip        TEXT,
	"round"   TEXT,
	created   TIMESTAMP,
	updated   TIMESTAMP
);

CREATE TABLE votes (
	id         INTEGER PRIMARY KEY,
	record_id  INTEGER REFERENCES vote_records(id) ON DELETE CASCADE,
	story_id   INTEGER REFERENCES storys(id) ON DELETE CASCADE,
	image_id   INTEGER REFERENCES images(id) ON DELETE CASCADE,
	"value"    INTEGER
);

CREATE TABLE scoreboard (
	competitor  TEXT PRIMARY KEY,
	"score"     INTEGER,
	"awards"    TEXT,
	created     TIMESTAMP,
	updated     TIMESTAMP
);