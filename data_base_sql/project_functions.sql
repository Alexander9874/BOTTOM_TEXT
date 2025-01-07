CREATE OR REPLACE FUNCTION project_Create(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31),
    p_description VARCHAR(255)
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

----

CREATE OR REPLACE FUNCTION project_Delete(
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
    WHERE projectname = input_projectname
	AND id_user = id_user_proc
	AND deleted = false;

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

----

CREATE OR REPLACE PROCEDURE project_CleanDeleted()
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

----

CREATE OR REPLACE FUNCTION project_Update(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31),
    p_new_projectname VARCHAR(31),
    p_new_description VARCHAR(255)
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

----

CREATE OR REPLACE FUNCTION project_Publish(
    input_username VARCHAR(31),
    input_projectname VARCHAR(31)
)
RETURNS INT AS $$
DECLARE
    id_user_proc INT;
    id_project_proc INT;
BEGIN
    -- Получаем id пользователя
    SELECT id_user INTO id_user_proc
    FROM Users
    WHERE username = input_username;

    IF NOT FOUND THEN
        RETURN 1; -- Пользователь не найден
    END IF;

    -- Получаем id проекта и проверяем, принадлежит ли проект пользователю
    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname
      AND id_user = id_user_proc
	  AND deleted = false;

    IF NOT FOUND THEN
        RETURN 1; -- Проект не принадлежит пользователю
    END IF;

    -- Проверяем, опубликован ли проект (public = true)
    IF EXISTS (
        SELECT 1 FROM Projects
        WHERE id_project = id_project_proc
          AND public = TRUE
    ) THEN
        RETURN 1; -- Проект уже опубликован
    END IF;

    -- Обновляем флаг public и добавляем дату публикации
    UPDATE Projects
    SET public = TRUE,
        publish_date = CURRENT_TIMESTAMP
    WHERE id_project = id_project_proc;

    RETURN 0; -- Успешно опубликован
END;
$$ LANGUAGE plpgsql;


----

CREATE OR REPLACE FUNCTION project_GetByUser(
    username_victim VARCHAR(31),
    username_caller VARCHAR(31)
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    IF username_victim = username_caller THEN
        SELECT jsonb_agg(
            jsonb_build_object(
                'projectname', p.projectname,
                'create_date', p.create_date,
                'public', p.public,
                'publish_date', p.publish_date,
                'description', p.description,
                'likes_count', COALESCE(l.likes_count, 0),
                'caller_liked', EXISTS (
                    SELECT 1
                    FROM Likes l2
                    INNER JOIN Users uc ON l2.id_user = uc.id_user
                    WHERE l2.id_project = p.id_project
                      AND uc.username = username_caller
                )
            )
        )
        INTO result
        FROM Projects p
        INNER JOIN Users uv ON p.id_user = uv.id_user
        LEFT JOIN (
            SELECT id_project, COUNT(*)::INT AS likes_count
            FROM Likes
            GROUP BY id_project
        ) l ON p.id_project = l.id_project
        WHERE uv.username = username_victim
          AND p.deleted = FALSE;

    ELSE
        SELECT jsonb_agg(
            jsonb_build_object(
                'projectname', p.projectname,
                'create_date', p.create_date,
                'public', p.public,
                'publish_date', p.publish_date,
                'description', p.description,
                'likes_count', COALESCE(l.likes_count, 0),
                'caller_liked', EXISTS (
                    SELECT 1
                    FROM Likes l2
                    INNER JOIN Users uc ON l2.id_user = uc.id_user
                    WHERE l2.id_project = p.id_project
                      AND uc.username = username_caller
                )
            )
        )
        INTO result
        FROM Projects p
        INNER JOIN Users uv ON p.id_user = uv.id_user
        LEFT JOIN (
            SELECT id_project, COUNT(*)::INT AS likes_count
            FROM Likes
            GROUP BY id_project
        ) l ON p.id_project = l.id_project
        WHERE uv.username = username_victim
          AND p.public = TRUE
          AND p.deleted = FALSE;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION projects_GetAll(
    username_caller VARCHAR(31)
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

----

CREATE OR REPLACE FUNCTION project_GetAllSortedByLikes(
    username_caller VARCHAR(31),
    descend BOOLEAN
)
RETURNS SETOF JSON AS $$
BEGIN
    IF descend THEN
        RETURN QUERY
        SELECT row_to_json(t)
        FROM (
            SELECT 
                projectname, 
                create_date, 
                public, 
                publish_date, 
                description, 
                owner_username, 
                likes_count, 
                caller_liked
            FROM get_all_projects(username_caller)
            ORDER BY likes_count DESC NULLS LAST
        ) t;
    ELSE
        RETURN QUERY
        SELECT row_to_json(t)
        FROM (
            SELECT 
                projectname, 
                create_date, 
                public, 
                publish_date, 
                description, 
                owner_username, 
                likes_count, 
                caller_liked
            FROM get_all_projects(username_caller)
            ORDER BY likes_count ASC NULLS LAST
        ) t;
    END IF;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION project_GetAllSortedByDate(
    username_caller VARCHAR(31),
    descend BOOLEAN
)
RETURNS SETOF JSON AS $$
BEGIN
    IF descend THEN
        RETURN QUERY
        SELECT row_to_json(t)
        FROM (
            SELECT 
                projectname, 
                create_date, 
                public, 
                publish_date, 
                description, 
                owner_username, 
                likes_count, 
                caller_liked
            FROM get_all_projects(username_caller)
            ORDER BY publish_date DESC NULLS LAST
        ) t;
    ELSE
        RETURN QUERY
        SELECT row_to_json(t)
        FROM (
            SELECT 
                projectname, 
                create_date, 
                public, 
                publish_date, 
                description, 
                owner_username, 
                likes_count, 
                caller_liked
            FROM get_all_projects(username_caller)
            ORDER BY publish_date ASC NULLS LAST
        ) t;
    END IF;
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION project_Copy(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31),
    p_new_projectname VARCHAR(31)
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

----

CREATE OR REPLACE FUNCTION project_DoesExist(
	p_projectname VARCHAR(31)
)
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

----

CREATE OR REPLACE FUNCTION project_IsPublic(
    p_projectname VARCHAR(31)
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

----

CREATE OR REPLACE FUNCTION project_IsOwnedByUser(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31)
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
