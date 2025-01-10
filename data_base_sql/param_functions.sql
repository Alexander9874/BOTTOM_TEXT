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
				'colors_num', p.colors_num,
				'torus_mode', p.torus_mode,
				'blue_death_conditions', p.blue_death_conditions,
				'blue_birth_condittions', p.blue_birth_condittions,
				'blue_death_conditions_other', p.blue_death_conditions_other,
				'blue_birth_condittions_other', p.blue_birth_condittions_other,
				'green_death_conditions', p.green_death_conditions,
				'green_birth_condittions', p.green_birth_condittions,
				'green_death_conditions_other', p.green_death_conditions_other,
				'green_birth_condittions_other', p.green_birth_condittions_other,
				'violet_death_conditions', p.violet_death_conditions,
				'violet_birth_condittions', p.violet_birth_condittions,
				'violet_death_conditions_other', p.violet_death_conditions_other,
				'violet_birth_condittions_other', p.violet_birth_condittions_other,
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
	p_colors_num INT,
	p_torus_mode BOOLEAN,
	p_blue_death_conditions INT[],
	p_blue_birth_condittions INT[],
	p_blue_death_conditions_other INT[],
	p_blue_birth_condittions_other INT[],
	p_green_death_conditions INT[],
	p_green_birth_condittions INT[],
	p_green_death_conditions_other INT[],
	p_green_birth_condittions_other INT[],
	p_violet_death_conditions INT[],
	p_violet_birth_condittions INT[],
	p_violet_death_conditions_other INT[],
	p_violet_birth_condittions_other INT[],
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
    SET colors_num = p_colors_num,
		torus_mode = p_torus_mode,
		blue_death_conditions = p_blue_death_conditions,
		blue_birth_condittions = p_blue_birth_condittions ,
		blue_death_conditions_other = p_blue_death_conditions_other,
		blue_birth_condittions_other = p_blue_birth_condittions_other,
		green_death_conditions = p_green_death_conditions,
		green_birth_condittions = p_green_birth_condittions,
		green_death_conditions_other = p_green_death_conditions_other,
		green_birth_condittions_other = p_green_birth_condittions_other,
		violet_death_conditions = p_violet_death_conditions,
		violet_birth_condittions = p_violet_birth_condittions,
		violet_death_conditions_other = p_violet_death_conditions_other,
		violet_birth_condittions_other = p_violet_birth_condittions_other,
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
