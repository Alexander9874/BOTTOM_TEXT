CREATE OR REPLACE FUNCTION like_PutLike(
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

----

CREATE OR REPLACE FUNCTION like_RemoveLike(
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

    -- Получаем id проекта
    SELECT id_project INTO id_project_proc
    FROM Projects
    WHERE projectname = input_projectname;

    IF NOT FOUND THEN
        RETURN 1; -- Проект не найден
    END IF;

    -- Проверяем доступность проекта
    IF NOT EXISTS (
        SELECT 1 FROM Projects 
        WHERE id_project = id_project_proc 
          AND public = TRUE 
          AND deleted = FALSE
    ) THEN
        RETURN 1; -- Проект недоступен
    END IF;

    -- Проверяем, есть ли лайк пользователя на проекте
    IF NOT EXISTS (
        SELECT 1 FROM Likes 
        WHERE id_user = id_user_proc 
          AND id_project = id_project_proc
    ) THEN
        RETURN 1; -- Лайк отсутствует
    END IF;

    -- Удаляем лайк
    DELETE FROM Likes
    WHERE id_user = id_user_proc
      AND id_project = id_project_proc;

    RETURN 0; -- Успешное удаление
END;
$$ LANGUAGE plpgsql;

----

CREATE OR REPLACE FUNCTION like_Switch(
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
