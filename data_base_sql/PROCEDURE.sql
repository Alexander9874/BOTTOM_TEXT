CREATE OR REPLACE PROCEDURE do_like_by_id(
    input_id_user INT,
    input_id_project INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = input_id_project AND public = true AND deleted = false
    ) THEN
        RAISE EXCEPTION 'Project is not public or deleted.';
    END IF;

    INSERT INTO Likes (id_user, id_project)
    VALUES (input_id_user, input_id_project)
    ON CONFLICT DO NOTHING;
END;
$$;


CREATE OR REPLACE PROCEDURE do_like(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
LANGUAGE plpgsql
AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User % not found', input_username;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Project % not found.', input_projectname;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true AND deleted = false
    ) THEN
        RAISE EXCEPTION 'Project % is not public or deleted.', input_projectname;
    END IF;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE id_user = id_user_proc AND id_project = id_project_proc
    ) THEN
        RAISE EXCEPTION 'Like from user % for project % already exists.', input_username, input_projectname;
    END IF;

    INSERT INTO Likes (id_user, id_project)
    VALUES (id_user_proc, id_project_proc);
END;
$$;


CREATE OR REPLACE PROCEDURE do_like_unlike(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
LANGUAGE plpgsql
AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User % not found', input_username;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Project % not found.', input_projectname;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true AND deleted = false
    ) THEN
        RAISE EXCEPTION 'Project % is not public or deleted.', input_projectname;
    END IF;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE id_user = id_user_proc AND id_project = id_project_proc
    ) THEN
        DELETE FROM Likes
		WHERE id_user = id_user_proc AND id_project = id_project_proc;
	ELSE
    	INSERT INTO Likes (id_user, id_project)
    	VALUES (id_user_proc, id_project_proc);
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE delete_project(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
LANGUAGE plpgsql
AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'User % not found.', input_username;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname AND id_user = id_user_proc;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Project % not found or does not belongs to user %.', input_projectname, input_username;
    END IF;

    UPDATE Projects
    SET deleted = true
    WHERE id_project = id_project_proc;
END;
$$;


CREATE OR REPLACE PROCEDURE clean_deleted_projects()
LANGUAGE plpgsql
AS $$
DECLARE
    project_id INT;
    deleted_projects CURSOR FOR
        SELECT id_project FROM Projects WHERE deleted = TRUE;
BEGIN
    OPEN deleted_projects;

    LOOP
        FETCH deleted_projects INTO project_id;
        EXIT WHEN NOT FOUND;

        DELETE FROM Likes WHERE id_project = project_id;

        DELETE FROM Params WHERE id_project = project_id;

        DELETE FROM Projects WHERE id_project = project_id;
        
        RAISE NOTICE 'Project with id % completele deleted.', project_id;
    END LOOP;

    CLOSE deleted_projects;
END;
$$;


CREATE OR REPLACE FUNCTION create_user(username_input VARCHAR, password_input VARCHAR)
RETURNS INT AS $$
DECLARE
    user_exists BOOLEAN;
    password_hashed BIGINT;
BEGIN
    SELECT EXISTS(SELECT 1 FROM Users WHERE username = username_input) INTO user_exists;

    IF user_exists THEN
        RETURN 1;
    ELSE
        SELECT hashtext(password_input || username_input)::BIGINT INTO password_hashed;

        INSERT INTO Users (username, password_hash)
        VALUES (username_input, password_hashed);

        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_user_password(username_input VARCHAR, password_input VARCHAR)
RETURNS INT AS $$
DECLARE
    stored_password_hash BIGINT;
    input_password_hash BIGINT;
BEGIN
    SELECT password_hash INTO stored_password_hash
    FROM Users
    WHERE username = username_input;

    IF NOT FOUND THEN
        RETURN 1;
    END IF;

    SELECT hashtext(password_input || username_input)::BIGINT INTO input_password_hash;

    IF stored_password_hash = input_password_hash THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;