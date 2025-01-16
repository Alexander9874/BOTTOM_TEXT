# DATABASE |>

import psycopg2
from typing import List


DATABASE_CONFIG = {
    "dbname": "bottom_text",
    "user": "alexander",
    "password": "PGpass",
    "host": "localhost",
    "port": 5432
}


def db_GetConnection():
    return psycopg2.connect(**DATABASE_CONFIG)


def db_Signup(username: str,
              password: str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()

        cur.execute("SELECT user_Create(%s, %s)",
                    (username, password))

        result = cur.fetchone()[0]
        cur.close()
        conn.commit()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error: {e}")
        return False


def db_Login(username: str,
             password: str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT user_CheckPassword(%s, %s)",
                    (username, password))
        result = cur.fetchone()[0]
        cur.close()
        conn.commit()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error: {e}")
        return False


def db_RevokeToken(token: str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("INSERT INTO RevokedTokens (token_text) VALUES (%s) ON CONFLICT DO NOTHING",
                    (token,))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error revoking token: {e}")


def db_IsTokenRevoked(token: str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM RevokedTokens WHERE token_text = %s",
                    (token,))
        result = cur.fetchone()[0]
        cur.close()
        conn.close()
        return result > 0
    except Exception as e:
        print(f"Error checking token: {e}")
        return True


def db_UpdateAboutMe(username : str,
                     about_me : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT user_UpdateAboutMe(%s, %s)",
                    (username, about_me))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False
    

def db_GetUserInfo(username: str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM user_GetInfo(%s)",
                    (username,)
        )
        result = cur.fetchall()

        if result and isinstance(result[0],
                                 tuple):
            result = result[0][0]
        else:
            raise ValueError("Wrong JSON format")

        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []


def db_CreateProject(username : str,
                     projectname : str,
                     description : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_Create(%s, %s, %s)",
                    (username, projectname, description))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_DeleteProject(username : str,
                     projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_Delete(%s, %s)",
                    (username, projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_UpdateProject(username : str,
                     projectname : str,
                     new_projectname : str,
                     new_description : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_Update(%s, %s, %s, %s)",
                    (username, projectname, new_projectname, new_description))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_PublishProject(username : str,
                      projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_Publish(%s, %s)",
                    (username, projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_CopyProject(username : str,
                   projectname : str,
                   new_projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_Copy(%s, %s, %s)",
                    (username, projectname, new_projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_GetProjectsByUser(username_victim: str,
                         username_caller: str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM project_GetByUser(%s, %s)",
                    (username_victim, username_caller))
        result = cur.fetchall()

        if result and isinstance(result[0],
                                 tuple):
            result = result[0][0]
        else:
            raise ValueError("Wrong JSON format")

        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []


def db_GetAllProjectsSortedByLikes(username: str,
                                   desc: bool):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM project_GetAllSortedByLikes(%s, %s)",
                    (username, desc))
        result = cur.fetchall()
        result = [row[0] for row in result]
        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []


def db_GetAllProjectsSortedByDate(username: str,
                                  desc: bool):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM project_GetAllSortedByDate(%s, %s)",
                    (username, desc))
        result = cur.fetchall()
        result = [row[0] for row in result]
        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []


def db_UpdateParam(username: str,
                   project_name: str,
                   colors_num : int,
	               torus_mode: bool,
	               blue_death_conditions: List[int],
	               blue_birth_conditions: List[int],
	               blue_death_conditions_other: List[int],
	               blue_birth_conditions_other: List[int],
	               green_death_conditions: List[int],
	               green_birth_conditions: List[int],
	               green_death_conditions_other: List[int],
	               green_birth_conditions_other: List[int],
	               violet_death_conditions: List[int],
	               violet_birth_conditions: List[int],
	               violet_death_conditions_other: List[int],
	               violet_birth_conditions_other: List[int],
                   grid: List[int]) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT param_Update(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                    (username,
                     project_name,
                     colors_num,
                     torus_mode,
                     blue_death_conditions,
                     blue_birth_conditions,
                     blue_death_conditions_other,
                     blue_birth_conditions_other,
                     green_death_conditions,
                     green_birth_conditions,
                     green_death_conditions_other,
                     green_birth_conditions_other,
                     violet_death_conditions,
                     violet_birth_conditions,
                     violet_death_conditions_other,
                     violet_birth_conditions_other,
                     grid))
        result = cur.fetchone()[0]
        
        conn.commit()
        cur.close()
        conn.close()
        
        return result == 0
    except Exception as e:
        print(f"Error: {e}")
        return False


def db_GetParam(username: str,
                projectname : str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM param_Get(%s, %s)",
                    (username, projectname))
        result = cur.fetchall()

        if result and isinstance(result[0],
                                 tuple):
            result = result[0][0][0]
        else:
            raise ValueError("Wrong JSON format")

        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []


def db_PutLike(username : str,
               projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT like_PutLike(%s, %s)",
                    (username, projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_RemoveLike(username : str,
                  projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT like_RemoveLike(%s, %s)",
                    (username, projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False


def db_SwitchLike(username : str,
                  projectname : str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT like_Switch(%s, %s)",
                    (username, projectname))
        result = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error : {e}")
        return False

def db_CleanDeletedProjects():
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("CALL project_CleanDeleted()")
        conn.commit()
        cur.close()
        conn.close()
        return
    except Exception as e:
        print(f"Error : {e}")
        return

def db_CleanRevokedToken():
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("DELETE FROM RevokedTokens WHERE revoked_time < NOW() - INTERVAL '2 hours';")
        conn.commit()
        cur.close()
        conn.close()
        return
    except Exception as e:
        print(f"Error : {e}")
        return

def db_GetProjectInfo(username: str,
                      projectname : str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM project_GetProjectInfo(%s, %s)",
                    (username, projectname))
        result = cur.fetchall()

        if result and isinstance(result[0],
                                 tuple):
            result = result[0][0]
        else:
            raise ValueError("Wrong JSON format")

        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []

def db_GetProjectGrid(projectname: str):
    conn = db_GetConnection()
    cur = conn.cursor()
    # Pass the projectname as a tuple
    cur.execute("SELECT * FROM param_GetGrid(%s)", (projectname,))
    result = cur.fetchall()
    cur.close()
    conn.close()
    return result

# <| END DATABASE