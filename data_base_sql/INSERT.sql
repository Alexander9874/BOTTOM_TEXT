INSERT INTO Users (username, password_hash, about_me)
VALUES
    ('user1', 123456789, 'I love coding.'),
    ('user2', 987654321, 'Data scientist and engineer.'),
    ('user3', 112233445, 'Backend developer.');


INSERT INTO Projects (id_user, projectname)
VALUES
    (1, 'Project 1'),
    (1, 'Project 2'),
    (2, 'Project 3'),
    (2, 'Project 4'),
    (3, 'Project 5');

INSERT INTO Params (id_project, param1, param2, grid)
VALUES
    (1, 1, 1, '{1}'),
    (2, 2, 2, '{2, 2}'),
    (3, 3, 3, '{3, 3, 3}'),
    (4, 4, 4, '{4, 4, 4, 4}'),
    (5, 5, 5, '{5, 5, 5, 5, 5}');


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP
WHERE id_project = 1;


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP
WHERE id_project = 3;


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP
WHERE id_project = 5;

UPDATE Projects
SET
	deleted = true
WHERE id_project = 1;

UPDATE Projects
SET
	deleted = true
WHERE id_project = 2;

CALL do_like_by_id(1, 5); -- ok

CALL do_like_by_id(1, 4); -- not ok


CALL do_like('user1', 'Project 5'); -- already exists

CALL do_like('user1', 'Project 3'); -- ok


CALL do_like_unlike('user1', 'Project 3');

CALL do_like_unlike('user3', 'Project 5');

CALL do_like_unlike('user1', 'Project 4'); -- private

CALL do_like_unlike('user2', 'Project 1'); -- deleted


CALL delete_project('user1', 'Project 1');

CALL delete_project('user2', 'Project 4');

CALL delete_project('user1', 'Project 5');


CALL clean_deleted_projects();


SELECT create_user('new_user', 'my_secure_password');

SELECT check_user_password('existing_user', 'password_to_check');

SELECT create_user('existing_user', 'password_to_check');

SELECT check_user_password('existing_user', 'password_to_check');
