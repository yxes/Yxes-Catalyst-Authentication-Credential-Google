--
-- Create a very simple database to act as a placeholder for testing
--

--
-- USAGE: 'sqlite3 testapp.db < testapp.sql'
--

PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id		 INTEGER PRIMARY KEY,
  email		 VARCHAR(255) NOT NULL,
  link		 VARCHAR(255),
  name		 VARCHAR(30),
  locale	 VARCHAR(10),
  family_name    VARCHAR(60),
  given_name	 VARCHAR(30),
  google_id	 VARCHAR(50),
  verified_email TINYINT,
  birthday	 DATE,
--  hd		 VARCHAR(255),
  picture	 VARCHAR(255),
  gender	 VARCHAR(30),
  active	 TINYINT NOT NULL DEFAULT '1'
);

CREATE TABLE user_roles (
  user_id	INTEGER,
  role_id	INTEGER,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE roles (
  id		INTEGER PRIMARY KEY,
  role		varchar(50)
);

CREATE TABLE token (
  id		INTEGER PRIMARY KEY,
  set_time	DATETIME,
  expires_in	INTEGER,
  id_token	TEXT,
  refresh_token	VARCHAR(255),
  access_token  VARCHAR(255),
  token_type	VARCHAR(30),
  FOREIGN KEY(id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TRIGGER add_role AFTER INSERT ON users BEGIN INSERT INTO user_roles VALUES(NEW.id,'1'); END;

INSERT INTO roles(role) VALUES('user');
INSERT INTO roles(role) VALUES('admin');
INSERT INTO roles(role) VALUES('nobody');

INSERT INTO users(email) VALUES('user@localhost');
INSERT INTO users(email) VALUES('test@user');

INSERT INTO user_roles VALUES(1,2);
INSERT INTO user_roles VALUES(2,3);
