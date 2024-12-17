from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Security


from pydantic import BaseModel

from typing import List


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


# Подключение к PostgreSQL
def db_GetConnection():
    return psycopg2.connect(**DATABASE_CONFIG)


# Регистрации пользователя
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


# Логин пользователя
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


# Отзыв JWT токена
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


# Проверка отзыва JWT токена
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
                    (username,))
        result = cur.fetchall()

        if result and isinstance(result[0], tuple):
            result = result[0][0]
        # TODO else throw exception SQl returns bad format

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

        if result and isinstance(result[0], tuple):
            result = result[0][0]
        # TODO else throw exception SQl returns bad format

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
                   param1: int,
                   param2: int,
                   param_array: List[int]) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        
        cur.execute(
            "SELECT param_Update(%s, %s, %s, %s, %s)",
            (username, project_name, param1, param2, param_array),
        )
        
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

        if result and isinstance(result[0], tuple):
            result = result[0][0][0]
        # TODO как предыдущее todo

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

# <| END DATABASE

# JWT |>

from jose import JWTError, jwt
import time


# Конфигурация
SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 120


# Функция создания JWT токена
def jwt_CreateToken(data: dict, expires_delta: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    to_encode = data.copy()
    to_encode.update({"exp": time.time() + expires_delta * 60})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


security = HTTPBearer()


def jwt_VerifyToken(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    try:
        # Проверяем, отозван ли токен
        if db_IsTokenRevoked(token):
            raise HTTPException(status_code=401, detail="Token has been revoked")

        # Проверяем валидность токена
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


# Функция для извлечения username из JWT токена
def jwt_GetUsername(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")
        return username
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

# <| END JWT


# API |>

app = FastAPI()


class api_UserPassword_req (BaseModel):
    username: str
    password: str

class api_AboutMe_req(BaseModel):
    about_me: str

class api_ProjectnameDescription_req(BaseModel):
    projectname: str
    description: str

class api_Projectname_req(BaseModel):
    projectname: str

class api_NewProjectnameDescription_req(BaseModel):
    projectname : str
    new_projectname : str
    new_description : str

class api_NewProjectname_req (BaseModel):
    projectname : str
    new_projectname: str

class api_Username_req(BaseModel):
    username: str

class api_SortDesc_req(BaseModel):
    sort_by: str    # DATE or LIKE
    desc: bool

class api_Param_req(BaseModel):
    projectname: str
    param1: int
    param2: int
    param_array: List[int]


@app.get("/", response_class=HTMLResponse)
async def api_GetRoot():
    with open("index.html", "r", encoding="utf-8") as f:
        return f.read()


@app.get("/protected", response_class=HTMLResponse)
async def api_GetProtected(payload: dict = Depends(jwt_VerifyToken)):
    with open("protected.html", "r", encoding="utf-8") as f:
        return f.read()


@app.post("/signup")
async def api_Signup(request: api_UserPassword_req):
    if db_Signup(request.username, request.password):
        return {"detail": "Registration successful"}
    else:
        raise HTTPException(status_code=400, detail="Registration failed")


@app.post("/login")
async def api_Login(data: api_UserPassword_req):
    if db_Login(data.username, data.password):
        token = jwt_CreateToken({"sub": data.username})
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Invalid username or password")


@app.post("/logout")
async def api_Logout(credentials: HTTPAuthorizationCredentials = Security(security), username: str = Depends(jwt_GetUsername)):
    token = credentials.credentials
    db_RevokeToken(token)
    return {"detail": "Logout successful. Token revoked."}


@app.post("/UpdateAuboutMe")
async def api_UpdateAboutMe(request: api_AboutMe_req, username: str = Depends(jwt_GetUsername)):
    success = db_UpdateAboutMe(username, request.about_me)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")


# def db_GetUserInfo(username: str):


@app.get("/GetUserInfo")
async def api_GetUserInfo(username: str = Depends(jwt_GetUsername)):
    try:
        result = db_GetUserInfo(username)

        if not result:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")






@app.post("/CreateProject")
async def api_CreateProject(request: api_ProjectnameDescription_req, username: str = Depends(jwt_GetUsername)):
    success = db_CreateProject(username, request.projectname, request.description)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")


# TODO:
# Есть возможность посылать удаление одного проекта много раз
# И каждый раз получать ответ 200
# Нужно поправить это в БД
@app.post("/DeleteProject")
async def api_DeleteProject(request: api_Projectname_req, username: str = Depends(jwt_GetUsername)):
    success = db_DeleteProject(username, request.projectname)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")


@app.post("/UpdateProject")
async def api_UpdateProject(request: api_NewProjectnameDescription_req, username: str = Depends(jwt_GetUsername)):
    success = db_UpdateProject(username, request.projectname, request.new_projectname, request.new_description)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")


@app.post("/PublishProject")
async def api_PublishProject(request: api_Projectname_req, username: str = Depends(jwt_GetUsername)):
    success = db_PublishProject(username, request.projectname)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")


@app.post("/CopyProject")
async def api_CopyProject(request: api_NewProjectname_req,
                       username: str = Depends(jwt_GetUsername)):
    success = db_CopyProject(username,
                             request.projectname,
                             request.new_projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")
    

@app.get("/GetProjectsByUser")
async def api_GetProjectsByUser(request: api_Username_req,
                              username: str = Depends(jwt_GetUsername)):
    try:
        result = db_GetProjectsByUser(request.username,
                                       username)
        
        if not result:
            raise HTTPException(status_code=404, detail="No projects found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")


@app.get("/GetAllProjects")
async def api_GetAllProjects(request: api_SortDesc_req, username: str = Depends(jwt_GetUsername)):
    if request.sort_by == "DATE":
        sort_by_date = True
    elif request.sort_by == "LIKE":
        sort_by_date = False
    else:
        raise HTTPException(status_code=400, detail="Bad Request")

    try:
        if sort_by_date:
            result = db_GetAllProjectsSortedByDate(username, request.desc)
        else:
            result = db_GetAllProjectsSortedByLikes(username, request.desc)
        
        if not result:
            raise HTTPException(status_code=404, detail="No projects found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")


@app.post("/UpdateParam")
async def api_UpdateParam(request: api_Param_req, 
                       username: str = Depends(jwt_GetUsername)
):
    result = db_UpdateParam(
        username=username,
        project_name=request.projectname,
        param1=request.param1,
        param2=request.param2,
        param_array=request.param_array
    )
    
    if result:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update parameters")


@app.get("/GetParam")
async def api_GetParam(request: api_Projectname_req,
                     username: str = Depends(jwt_GetUsername)):
    try:
        result = db_GetParam(username, request.projectname)

        if not result:
            raise HTTPException(status_code=404, detail="No projects found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")


@app.post("/PutLike")
async def api_PutLike(request: api_Projectname_req,
              username: str = Depends(jwt_GetUsername)):
    success = db_PutLike(username,
                         request.projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.post("/RemoveLike")
async def api_RemoveLike(request: api_Projectname_req,
              username: str = Depends(jwt_GetUsername)):
    success = db_RemoveLike(username,
                            request.projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.post("/SwitchLike")
async def api_SwitchLike(request: api_Projectname_req,
              username: str = Depends(jwt_GetUsername)):
    success = db_SwitchLike(username,
                            request.projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")