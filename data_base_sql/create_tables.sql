DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Projects CASCADE;
DROP TABLE IF EXISTS Likes CASCADE;
DROP TABLE IF EXISTS Params CASCADE;
DROP TABLE IF EXISTS RevokedTokens CASCADE;

CREATE TABLE Users (
    id_user SERIAL PRIMARY KEY,
    username VARCHAR(31) NOT NULL UNIQUE,
    password_hash BIGINT NOT NULL,
    about_me VARCHAR(255) DEFAULT 'about me is empty',
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
	colors_num INT NOT NULL DEFAULT 1,
	torus_mode BOOLEAN NOT NULL DEFAULT (false),
	blue_death_conditions INT[] NOT NULL DEFAULT '{8}',
	blue_birth_condittions INT[] NOT NULL DEFAULT '{0, 3}',
	blue_death_conditions_other INT[] DEFAULT '{7}',
	blue_birth_condittions_other INT[] DEFAULT '{6}',
	green_death_conditions INT[] DEFAULT '{8}',
	green_birth_condittions INT[] DEFAULT '{3}',
	green_death_conditions_other INT[] DEFAULT '{7}',
	green_birth_condittions_other INT[] DEFAULT '{6}',
	violet_death_conditions INT[] DEFAULT '{8}',
	violet_birth_condittions INT[] DEFAULT '{4}',
	violet_death_conditions_other INT[] DEFAULT '{6}',
	violet_birth_condittions_other INT[] DEFAULT '{5}',
    grid INT[] NOT NULL DEFAULT '{0, 0, 0}'
);

CREATE TABLE RevokedTokens (
    id_token SERIAL PRIMARY KEY,
    token_text TEXT NOT NULL UNIQUE,
    revoked_time TIMESTAMP DEFAULT NOW()
);
