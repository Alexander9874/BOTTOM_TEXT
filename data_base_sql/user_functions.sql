CREATE OR REPLACE FUNCTION user_Create(
	username_input VARCHAR(31),
	password_input VARCHAR(255)
)
RETURNS INT AS $$
DECLARE
    user_exists BOOLEAN;
    password_hashed BIGINT;
BEGIN
    SELECT EXISTS(SELECT 1 FROM Users WHERE username = username_input) INTO user_exists;

    IF user_exists THEN
		-- user already exists
        RETURN 1;
    ELSE
        SELECT hashtext(password_input || username_input)::BIGINT INTO password_hashed;

        INSERT INTO Users (username, password_hash)
        VALUES (username_input, password_hashed);
		-- done
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION user_CheckPassword(
	username_input VARCHAR(31),
	password_input VARCHAR(255)
)
RETURNS INT AS $$
DECLARE
    stored_password_hash BIGINT;
    input_password_hash BIGINT;
BEGIN
    SELECT password_hash INTO stored_password_hash
    FROM Users
    WHERE username = username_input;

    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    SELECT hashtext(password_input || username_input)::BIGINT INTO input_password_hash;

    IF stored_password_hash = input_password_hash THEN
		-- done
        RETURN 0;
    ELSE
		-- wrong password
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION user_UpdateAboutMe(
	p_username VARCHAR(31),
	p_about_me VARCHAR(255)
)
RETURNS INT AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE username = p_username) THEN
        UPDATE Users
        SET about_me = p_about_me
        WHERE username = p_username;
		-- done
        RETURN 0;
    ELSE
		-- user not found
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION user_DoesExist(
	p_username VARCHAR(31)
)
RETURNS INT AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Users
        WHERE username = p_username
    ) THEN
		-- user exists 
        RETURN 0;
    ELSE
		-- user does not exist
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;
