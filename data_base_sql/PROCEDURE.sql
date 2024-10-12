CREATE OR REPLACE PROCEDURE do_like_by_id(
    input_id_user INT,
    input_id_project INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = input_id_project AND public = true
    ) THEN
        RAISE EXCEPTION 'Project is not public.';
    END IF;

    INSERT INTO Likes (id_user, id_project)
    VALUES (input_id_user, input_id_project)
    ON CONFLICT DO NOTHING;

    UPDATE Projects
    SET likes_count = COALESCE(likes_count, 0) + 1
    WHERE id_project = input_id_project;
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
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true
    ) THEN
        RAISE EXCEPTION 'Project % is not public.', input_projectname;
    END IF;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE id_user = id_user_proc AND id_project = id_project_proc
    ) THEN
        RAISE EXCEPTION 'Like from user % for project % already exists.', input_username, input_projectname;
    END IF;

    INSERT INTO Likes (id_user, id_project)
    VALUES (id_user_proc, id_project_proc);

    UPDATE Projects
    SET likes_count = COALESCE(likes_count, 0) + 1
    WHERE id_project = id_project_proc;

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
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true
    ) THEN
        RAISE EXCEPTION 'Project % is not public.', input_projectname;
    END IF;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE id_user = id_user_proc AND id_project = id_project_proc
    ) THEN
        DELETE FROM Likes
		WHERE id_user = id_user_proc AND id_project = id_project_proc;

		UPDATE Projects
	    SET likes_count = COALESCE(likes_count, 0) - 1
	    WHERE id_project = id_project_proc;
	ELSE
    	INSERT INTO Likes (id_user, id_project)
    	VALUES (id_user_proc, id_project_proc);

   		UPDATE Projects
	    SET likes_count = COALESCE(likes_count, 0) + 1
	    WHERE id_project = id_project_proc;
    END IF;
END;
$$;