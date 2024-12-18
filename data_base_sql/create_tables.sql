DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Projects CASCADE;
DROP TABLE IF EXISTS Likes CASCADE;
DROP TABLE IF EXISTS Params CASCADE;
DROP TABLE IF EXISTS RevokedTokens CASCADE;

CREATE TABLE Users (
    id_user SERIAL PRIMARY KEY,
    username VARCHAR(31) NOT NULL UNIQUE,
    password_hash BIGINT NOT NULL,
    about_me VARCHAR(255),
	create_date TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE Projects (
    id_project SERIAL PRIMARY KEY,
    id_user INT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES Users (id_user),
    projectname VARCHAR(31) NOT NULL UNIQUE,
    create_date TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    public BOOLEAN NOT NULL DEFAULT (false),
    publish_date TIMESTAMP,
    description VARCHAR(255),
    deleted BOOLEAN NOT NULL DEFAULT (false)
);

CREATE TABLE Likes(
    id_project INT NOT NULL,
    id_user INT NOT NULL,
    FOREIGN KEY (id_user) REFERENCES Users (id_user),
    FOREIGN KEY (id_project) REFERENCES Projects (id_project)
);

CREATE TABLE Params (
    id_params SERIAL PRIMARY KEY,
    id_project INT NOT NULL UNIQUE,
    FOREIGN KEY (id_project) REFERENCES Projects (id_project),
    param1 INT NOT NULL,
    param2 INT NOT NULL,
    grid INT[]
);

CREATE TABLE RevokedTokens (
    id_token SERIAL PRIMARY KEY,
    token_text TEXT NOT NULL UNIQUE,
    revoked_time TIMESTAMP DEFAULT NOW()
);
