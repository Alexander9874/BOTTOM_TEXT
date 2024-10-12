INSERT INTO Users (username, password_hash, about_me)
VALUES
    ('user1', 123456789, 'I love coding.'),
    ('user2', 987654321, 'Data scientist and engineer.'),
    ('user3', 112233445, 'Backend developer.');


INSERT INTO Projects (id_user, projectname, params, grid)
VALUES
    (1, 'Project A', 'param1=value1', 'grid data A'),
    (1, 'Project B', 'param2=value2', 'grid data B'),
    (2, 'Project C', 'param3=value3', 'grid data C'),
    (2, 'Project D', 'param4=value4', 'grid data D'),
    (3, 'Project E', 'param5=value5', 'grid data E');


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP,
    likes_count = 0
WHERE id_project = 1;


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP,
    likes_count = 0
WHERE id_project = 3;


UPDATE Projects
SET 
    public = true,
    publish_date = CURRENT_TIMESTAMP,
    likes_count = 0
WHERE id_project = 5;


CALL do_like_by_id(1, 5); --ok

CALL do_like_by_id(1, 4);--not ok

CALL do_like('user1', 'Project E'); -- already exists

CALL do_like('user1', 'Project C');

CALL do_like_unlike('user1', 'Project C');