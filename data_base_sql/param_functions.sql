CREATE OR REPLACE FUNCTION param_Get(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31)
)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Check if the user has access to the project
    IF EXISTS (
        SELECT 1
        FROM Projects p
        INNER JOIN Users u ON p.id_user = u.id_user
        WHERE p.projectname = p_projectname
          AND (p.public = TRUE OR u.username = p_username)
          AND p.deleted = FALSE
    ) THEN
        -- Fetch data and build JSON response
        SELECT json_agg(
            json_build_object(
                'param1', p.param1,
                'param2', p.param2,
                'grid', p.grid
            )
        )
        INTO result
        FROM Params p
        INNER JOIN Projects pr ON p.id_project = pr.id_project
        WHERE pr.projectname = p_projectname;

        -- Return the result as JSON
        RETURN COALESCE(result, '[]'::json); -- Empty JSON array if no data
    ELSE
        -- Raise an exception if access is denied
        RAISE EXCEPTION 'Project "%" does not exist or access denied.', p_projectname;
    END IF;
END;
$$ LANGUAGE plpgsql;


----

CREATE OR REPLACE FUNCTION param_Update(
    p_username VARCHAR(31),
    p_projectname VARCHAR(31),
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
