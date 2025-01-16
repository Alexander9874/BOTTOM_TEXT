-- user_functions.sql


SELECT user_Create('user1', 'user1');
SELECT user_Create('user2', 'user2');
SELECT user_Create('user3', 'user3');
SELECT user_Create('user4', 'user4');
SELECT user_Create('user5', 'user5');


SELECT user_CheckPassword('user1', 'user1');
SELECT user_CheckPassword('user2', 'user2');
SELECT user_CheckPassword('user3', 'user3');
SELECT user_CheckPassword('user4', 'user4');
SELECT user_CheckPassword('user5', 'user5');


SELECT user_UpdateAboutMe('user1', 'I am user number 1!');
SELECT user_UpdateAboutMe('user2', 'I am user number 2!');
SELECT user_UpdateAboutMe('user3', 'I am user number 3!');
SELECT user_UpdateAboutMe('user4', 'I am user number 4!');
SELECT user_UpdateAboutMe('user5', 'I am user number 5!');

SELECT * FROM user_GetInfo('user1');

SELECT user_DoesExist('user5');


-- project_functions.sql


SELECT project_Create('user1', 'project11', 'This is project number 11!');
SELECT project_Create('user1', 'project12', 'This is project number 12!');
SELECT project_Create('user1', 'project13', 'This is project number 13!');
SELECT project_Create('user2', 'project21', 'This is project number 21!');
SELECT project_Create('user2', 'project22', 'This is project number 22!');
SELECT project_Create('user2', 'project23', 'This is project number 23!');
SELECT project_Create('user2', 'project24', 'This is project number 24!');
SELECT project_Create('user3', 'project31', 'This is project number 31!');
SELECT project_Create('user4', 'project41', 'This is project number 41!');
SELECT project_Create('user4', 'project42', 'This is project number 42!');
SELECT project_Create('user4', 'project43', 'This is project number 43!');
SELECT project_Create('user5', 'project51', 'This is project number 51!');
SELECT project_Create('user5', 'project52', 'This is project number 52!');


SELECT project_Delete('user3', 'project31');
-- WRONG BELOW
SELECT project_Delete('user1', 'project31');


SELECT project_Update('user1', 'project13', 'PROJECT13', 'THIS IS PROJECT NUMBER 13!');
SELECT project_Update('user2', 'project21', 'PROJECT21', 'THIS IS PROJECT NUMBER 13!');
SELECT project_Update('user5', 'project51', 'PROJECT51', 'THIS IS PROJECT NUMBER 13!');
-- WRONG BELOW
SELECT project_Update('user1', 'project22', 'PROJECT22', 'THIS IS PROJECT NUMBER 22!');
SELECT project_Update('user3', 'project31', 'PROJECT31', 'THIS IS PROJECT NUMBER 31!');


SELECT project_Publish('user1', 'project11');
SELECT project_Publish('user2', 'PROJECT21');
SELECT project_Publish('user4', 'project41');
SELECT project_Publish('user5', 'PROJECT51');
-- WRONG BELOW
SELECT project_Publish('user1', 'project11');
SELECT project_Publish('user1', 'project52');
SELECT project_Publish('user3', 'project31');


SELECT project_Copy('user3', 'project11', 'project11copy');
SELECT project_Copy('user5', 'project52', 'project52copy');
-- WRONG BELOW
SELECT project_Copy('user3', 'project11', 'project11copy');
SELECT project_Copy('user5', 'project12', 'project12copy');


SELECT project_GetByUser('user1', 'user2');
SELECT project_GetByUser('user1', 'user1');
SELECT project_GetByUser('user3', 'user3');


SELECT projects_GetAll('user1');
SELECT project_GetAllSortedByLikes('user1', TRUE);
SELECT project_GetAllSortedByLikes('user1', FALSE);
SELECT project_GetAllSortedByDate('user1', TRUE);
SELECT project_GetAllSortedByDate('user1', FALSE);


SELECT project_DoesExist('project12');
SELECT project_DoesExist('project00');


SELECT project_IsPublic('project11');
SELECT project_IsPublic('project12');


SELECT project_IsOwnedByUser('user1', 'project12');
SELECT project_IsOwnedByUser('user2', 'project12');


-- param_functions.sql


SELECT param_Update('user1', 'project12', 222, false, ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 222], ARRAY[222, 222, 22284, 444343, 4434343, 44344343]);


SELECT param_Get('user1', 'project12');
SELECT param_Get('user2', 'project11');
-- WRONG BELOW
-- SELECT param_Get('user2', 'project12');
-- SELECT param_Get('user3', 'project31');


-- like_functions.sql

SELECT like_PutLike('user1', 'project11');
SELECT like_PutLike('user1', 'PROJECT21');
SELECT like_PutLike('user1', 'project41');
SELECT like_PutLike('user1', 'PROJECT51');
SELECT like_PutLike('user2', 'project11');
SELECT like_PutLike('user2', 'PROJECT21');
SELECT like_PutLike('user2', 'project41');
SELECT like_PutLike('user2', 'PROJECT51');
SELECT like_PutLike('user3', 'project11');
SELECT like_PutLike('user3', 'PROJECT21');
SELECT like_PutLike('user3', 'project41');
SELECT like_PutLike('user4', 'project11');
SELECT like_PutLike('user4', 'PROJECT21');
SELECT like_PutLike('user4', 'project41');
SELECT like_PutLike('user5', 'project11');
SELECT like_PutLike('user5', 'PROJECT21');
SELECT like_PutLike('user5', 'project41');


SELECT like_RemoveLike('user5', 'project41');

SELECT like_Switch('user5', 'project41');
SELECT like_Switch('user5', 'project41');


SELECT project_GetAllSortedByLikes('user1', TRUE);
SELECT project_GetAllSortedByLikes('user3', FALSE);


SELECT project_GetProjectInfo('user1', 'project11');
SELECT project_GetProjectInfo('user2', 'project11');
SELECT project_GetProjectInfo('user1', 'project24');