------------------------------------------
------------------------------------------
------------------------------------------
--        IF EVERYTHING WORKS           --
--          DELETE THIS FILE            --
------------------------------------------
------------------------------------------
------------------------------------------



CREATE OR REPLACE FUNCTION like(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
RETURNS INT AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
        RETURN 1;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname;
    
    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true AND deleted = false
    ) THEN
		-- project not found
        RETURN 1;
    END IF;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE id_user = id_user_proc AND id_project = id_project_proc
    ) THEN
		-- project is already liked
        RETURN 1;
    END IF;

    INSERT INTO Likes (id_user, id_project)
    VALUES (id_user_proc, id_project_proc);
	-- done
	RETURN 0;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------

CREATE OR REPLACE FUNCTION like_unlike(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
RETURNS INT AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname;
    
    IF NOT FOUND THEN
        -- project not found
		RETURN 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM Projects WHERE id_project = id_project_proc AND public = true AND deleted = false
    ) THEN
		-- project not found 
        RETURN 1;
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
	-- done
	RETURN 0;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------

CREATE OR REPLACE FUNCTION delete_project(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
RETURNS INT AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;
    
    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname AND id_user = id_user_proc;

    IF NOT FOUND THEN
		-- project not found
        RETURN 1;
    END IF;

    UPDATE Projects
    SET deleted = true
    WHERE id_project = id_project_proc;
	-- done
	RETURN 0;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------

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

--------------------------------------------

CREATE OR REPLACE FUNCTION create_user(
	username_input VARCHAR,
	password_input VARCHAR
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

------------------------------------------

CREATE OR REPLACE FUNCTION check_user_password(
	username_input VARCHAR,
	password_input VARCHAR
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

---------------------------------------------------

CREATE OR REPLACE FUNCTION update_user_about_me(
	p_username VARCHAR,
	p_about_me VARCHAR
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

---------------------------------------

CREATE OR REPLACE FUNCTION does_user_exist(p_username VARCHAR)
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

-------------------------------------------

CREATE OR REPLACE FUNCTION does_project_exist(p_projectname VARCHAR)
RETURNS INT AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Projects
        WHERE projectname = p_projectname
    ) THEN
		-- project exists
        RETURN 0;
    ELSE
		-- project does not exists
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------

CREATE OR REPLACE FUNCTION get_user_projects(
    username_victim VARCHAR,
    username_caller VARCHAR
)
RETURNS TABLE(
    projectname VARCHAR,
    create_date TIMESTAMP,
    public BOOLEAN,
    publish_date TIMESTAMP,
    description VARCHAR,
    likes_count INT,
    caller_liked BOOLEAN
) AS $$
BEGIN
    IF username_victim = username_caller THEN
        RETURN QUERY
        SELECT 
            p.projectname, 
            p.create_date, 
            p.public, 
            p.publish_date, 
            p.description,
            COALESCE(l.likes_count, 0) AS likes_count,
            EXISTS (
                SELECT 1
                FROM Likes l2
                INNER JOIN Users uc ON l2.id_user = uc.id_user
                WHERE l2.id_project = p.id_project
                  AND uc.username = username_caller
            ) AS caller_liked
        FROM 
            Projects p
        INNER JOIN 
            Users uv ON p.id_user = uv.id_user
        LEFT JOIN 
            (SELECT id_project, COUNT(*)::INT AS likes_count
             FROM Likes
             GROUP BY id_project) l
        ON 
            p.id_project = l.id_project
        WHERE 
            uv.username = username_victim
            AND p.deleted = FALSE;
    ELSE
        RETURN QUERY
        SELECT 
            p.projectname, 
            p.create_date, 
            p.public, 
            p.publish_date, 
            p.description,
            COALESCE(l.likes_count, 0) AS likes_count,
            EXISTS (
                SELECT 1
                FROM Likes l2
                INNER JOIN Users uc ON l2.id_user = uc.id_user
                WHERE l2.id_project = p.id_project
                  AND uc.username = username_caller
            ) AS caller_liked
        FROM 
            Projects p
        INNER JOIN 
            Users uv ON p.id_user = uv.id_user
        LEFT JOIN 
            (SELECT id_project, COUNT(*)::INT AS likes_count
             FROM Likes
             GROUP BY id_project) l
        ON 
            p.id_project = l.id_project
        WHERE 
            uv.username = username_victim
            AND p.public = TRUE
            AND p.deleted = FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

--------------------------------------

CREATE OR REPLACE FUNCTION update_project(
    p_username VARCHAR,
    p_projectname VARCHAR,
    p_new_projectname VARCHAR,
    p_new_description VARCHAR
)
RETURNS INT AS $$
DECLARE
    v_id_user INT;
    v_id_project INT;
BEGIN
    SELECT id_user INTO v_id_user
    FROM Users
    WHERE username = p_username;

    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    SELECT id_project INTO v_id_project
    FROM Projects
    WHERE projectname = p_projectname AND id_user = v_id_user AND deleted = FALSE;

    IF NOT FOUND THEN
		-- project not found
        RETURN 1;
    END IF;

    UPDATE Projects
    SET 
        projectname = p_new_projectname,
        description = p_new_description
    WHERE id_project = v_id_project;
	-- done
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------

CREATE OR REPLACE FUNCTION create_project(
    p_username VARCHAR,
    p_projectname VARCHAR,
    p_description VARCHAR
)
RETURNS INT AS $$
DECLARE
    v_id_user INT;
    v_id_project INT;
BEGIN
    SELECT id_user INTO v_id_user
    FROM Users
    WHERE username = p_username;

    IF NOT FOUND THEN
		-- user not found
        RETURN 1;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Projects
        WHERE projectname = p_projectname
    ) THEN
		-- project already exists
        RETURN 1;
    END IF;

    INSERT INTO Projects (id_user, projectname, description)
    VALUES (v_id_user, p_projectname, p_description)
    RETURNING id_project INTO v_id_project;

    INSERT INTO Params (id_project, param1, param2, grid)
    VALUES (v_id_project, 1, 1, ARRAY[0, 1, 2, 3, 4]);
	-- done
    RETURN 0;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------

CREATE OR REPLACE FUNCTION get_all_projects(
    username_caller VARCHAR
)
RETURNS TABLE(
    projectname VARCHAR,
    create_date TIMESTAMP,
    public BOOLEAN,
    publish_date TIMESTAMP,
    description VARCHAR,
    owner_username VARCHAR,
    likes_count INT,
    caller_liked BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.projectname, 
        p.create_date, 
        p.public, 
        p.publish_date, 
        p.description,
        u.username AS owner_username,
        COALESCE(l.likes_count, 0) AS likes_count,
        EXISTS (
            SELECT 1
            FROM Likes l2
            INNER JOIN Users uc ON l2.id_user = uc.id_user
            WHERE l2.id_project = p.id_project
              AND uc.username = username_caller
        ) AS caller_liked
    FROM 
        Projects p
    INNER JOIN 
        Users u ON p.id_user = u.id_user
    LEFT JOIN 
        (SELECT id_project, COUNT(*)::INT AS likes_count
         FROM Likes
         GROUP BY id_project) l
    ON 
        p.id_project = l.id_project
    WHERE 
        p.public = TRUE
        AND p.deleted = FALSE;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------------------

CREATE OR REPLACE FUNCTION get_all_projects_sorted_by_likes(
    username_caller VARCHAR,
	descend BOOLEAN
)
RETURNS TABLE(
    projectname VARCHAR,
    create_date TIMESTAMP,
    public BOOLEAN,
    publish_date TIMESTAMP,
    description VARCHAR,
    owner_username VARCHAR,
    likes_count INT,
    caller_liked BOOLEAN
) AS $$
BEGIN
	IF descend THEN
	    RETURN QUERY
	    SELECT * 
	    FROM get_all_projects(username_caller)
	    ORDER BY likes_count DESC;
	ELSE
	    RETURN QUERY
	    SELECT * 
	    FROM get_all_projects(username_caller)
	    ORDER BY likes_count ASC;
	END IF;
END;
$$ LANGUAGE plpgsql;

-------------------------------------------------------

CREATE OR REPLACE FUNCTION get_all_projects_sorted_by_date(
    username_caller VARCHAR,
	descend BOOLEAN
)
RETURNS TABLE(
    projectname VARCHAR,
    create_date TIMESTAMP,
    public BOOLEAN,
    publish_date TIMESTAMP,
    description VARCHAR,
    owner_username VARCHAR,
    likes_count INT,
    caller_liked BOOLEAN
) AS $$
BEGIN
	IF descend THEN
	    RETURN QUERY
	    SELECT * 
	    FROM get_all_projects(username_caller)
	    ORDER BY publish_date DESC NULLS LAST;
	ELSE
	    RETURN QUERY
	    SELECT * 
	    FROM get_all_projects(username_caller)
	    ORDER BY publish_date ASC NULLS LAST;
	END IF;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_params(
    p_username VARCHAR,
    p_projectname VARCHAR
)
RETURNS TABLE(
    param1 INT,
    param2 INT,
    grid INT[]
) AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Projects p
        INNER JOIN Users u ON p.id_user = u.id_user
        WHERE p.projectname = p_projectname
          AND (p.public = TRUE OR u.username = p_username)
          AND p.deleted = FALSE
    ) THEN
        RETURN QUERY
        SELECT 
            p.param1, 
            p.param2, 
            p.grid
        FROM Params p
        INNER JOIN Projects pr ON p.id_project = pr.id_project
        WHERE pr.projectname = p_projectname;
    ELSE
        RAISE EXCEPTION 'Project "% does not exist or access denied.', p_projectname;
    END IF;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_params(
    p_username VARCHAR,
    p_projectname VARCHAR,
    p_param1 INT,
    p_param2 INT,
    p_grid INT[]
)
RETURNS INT AS $$
DECLARE
    v_id_project INT;
    v_id_user INT;
BEGIN
    -- Получаем ID проекта и ID пользователя
    SELECT p.id_project, u.id_user
    INTO v_id_project, v_id_user
    FROM Projects p
    INNER JOIN Users u ON p.id_user = u.id_user
    WHERE p.projectname = p_projectname
      AND u.username = p_username
      AND p.deleted = FALSE;

    -- Если проект не найден или не принадлежит пользователю, вернуть ошибку
    IF NOT FOUND THEN
        RETURN 1;
    END IF;

    -- Обновляем параметры проекта в таблице Params
    UPDATE Params
    SET param1 = p_param1,
        param2 = p_param2,
        grid = p_grid
    WHERE id_project = v_id_project;

    -- Если обновление выполнено успешно, возвращаем 0
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        -- В случае любой ошибки возвращаем 1
        RETURN 1;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------

CREATE OR REPLACE FUNCTION is_project_owned_by_user(
    p_username VARCHAR,
    p_projectname VARCHAR
)
RETURNS INT AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM Projects p
        INNER JOIN Users u ON p.id_user = u.id_user
        WHERE u.username = p_username
          AND p.projectname = p_projectname
          AND p.deleted = FALSE
    ) INTO v_exists;

    -- Если проект принадлежит пользователю, вернуть 0, иначе 1
    IF v_exists THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION is_project_public(
    p_projectname VARCHAR
)
RETURNS INT AS $$
DECLARE
    v_is_public BOOLEAN;
BEGIN
    SELECT p.public
    FROM Projects p
    WHERE p.projectname = p_projectname
      AND p.deleted = FALSE
    INTO v_is_public;

    -- Если public = TRUE, вернуть 0, иначе 1
    IF v_is_public THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------

CREATE OR REPLACE FUNCTION copy_project(
    p_username VARCHAR,
    p_projectname VARCHAR,
    p_new_projectname VARCHAR
)
RETURNS INT AS $$
DECLARE
    v_user_id INT;
    v_project_id INT;
    v_public BOOLEAN;
    v_new_project_id INT;
BEGIN
    -- Получаем id пользователя
    SELECT id_user
    INTO v_user_id
    FROM Users
    WHERE username = p_username;

    -- Проверяем существование проекта и его принадлежность/публичность
    SELECT p.id_project, p.public
    INTO v_project_id, v_public
    FROM Projects p
    INNER JOIN Users u ON p.id_user = u.id_user
    WHERE p.projectname = p_projectname
      AND (u.username = p_username OR p.public = TRUE)
      AND p.deleted = FALSE;

    -- Если проект не найден, то возвращаем ошибку
    IF NOT FOUND THEN
        RETURN 1;
    END IF;

    -- Проверяем уникальность имени нового проекта
    IF EXISTS (
        SELECT 1
        FROM Projects
        WHERE projectname = p_new_projectname
    ) THEN
        RETURN 1;
    END IF;

    -- Создаём копию проекта
    INSERT INTO Projects (id_user, projectname, description)
    VALUES (v_user_id, p_new_projectname, 'copied project')
    RETURNING id_project INTO v_new_project_id;

    -- Копируем параметры проекта
    INSERT INTO Params (id_project, param1, param2, grid)
    SELECT v_new_project_id, param1, param2, grid
    FROM Params
    WHERE id_project = v_project_id;

    RETURN 0;
END;
$$ LANGUAGE plpgsql;
