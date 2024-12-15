from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Security


from pydantic import BaseModel


#from psycopg2.extras import RealDictCursor



# DATABASE |>

import psycopg2
from typing import List, Dict, Any


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
def db_UserSignUp(username: str,
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
def db_UserLogIn(username: str,
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
    
def db_UserUpdateAboutMe(username : str,
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


def db_ProjectCreate(username : str,
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

def db_ProjectDelete(username : str,
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
    
def db_ProjectUpdate(username : str,
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

def db_ProjectPublish(username : str,
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

def db_ProjectCopy(username : str,
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

def db_ProjectGetByUser(username_victim: str,
                        username_caller: str) -> List[Dict[str, Any]]:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_GetByUser(%s, %s)",
                    (username_victim, username_caller))
        result = cur.fetchall()
        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []
    
def db_ProjectGetAllSortedByLikes(username: str,
                                  desc: bool) -> List[Dict[str, Any]]:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_GetAllSortedByLikes(%s, %s)",
                    (username, desc))
        result = cur.fetchall()
        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []

def db_ProjectGetAllSortedByDate(username: str,
                                  desc: bool) -> List[Dict[str, Any]]:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT project_GetAllSortedByDate(%s, %s)",
                    (username, desc))
        result = cur.fetchall()
        cur.close()
        conn.close()
        return result
    except Exception as e:
        print(f"Error: {e}")
        return []

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

app = FastAPI()

# 1. Возвращает HTML файл
@app.get("/", response_class=HTMLResponse)
async def get_html():
    with open("index.html", "r", encoding="utf-8") as f:
        return f.read()

# 2. Запрос к PostgreSQL и возвращение JSON
@app.get("/query", response_class=JSONResponse)
async def query_db(query: str):
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute(query)
        result = cur.fetchall()
        cur.close()
        conn.close()
        return {"result": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 4. Проверка JWT токена
@app.get("/protected", response_class=HTMLResponse)
async def protected_route(payload: dict = Depends(jwt_VerifyToken)):
    with open("protected.html", "r", encoding="utf-8") as f:
        return f.read()


# Модель данных для запроса signup и login
class UserPasswordRequest(BaseModel):
    username: str
    password: str

@app.post("/signup")
async def signup(request: UserPasswordRequest):
    if db_UserSignUp(request.username, request.password):
        return {"detail": "Registration successful"}
    else:
        raise HTTPException(status_code=400, detail="Registration failed")

@app.post("/login")
async def login(data: UserPasswordRequest):
    if db_UserLogIn(data.username, data.password):
        token = jwt_CreateToken({"sub": data.username})
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Invalid username or password")

@app.post("/logout")
async def logout(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    db_RevokeToken(token)
    return {"detail": "Logout successful. Token revoked."}
























class UpdateAboutMeRequest(BaseModel):
    about_me: str

@app.post("/userupdateuboutme")
async def update_about_me(request: UpdateAboutMeRequest, username: str = Depends(jwt_GetUsername)):
    success = db_UserUpdateAboutMe(username, request.about_me)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")



# db_ProjectCreate(username : str, projectname : str, description : str)

class ProjectCreate(BaseModel):
    projectname: str
    description: str

@app.post("/projectcreate")
async def project_create(request: ProjectCreate, username: str = Depends(jwt_GetUsername)):
    success = db_ProjectCreate(username, request.projectname, request.description)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")
    






# def db_ProjectDelete(username : str, projectname : str) -> bool:

class ProjectDelete(BaseModel):
    projectname: str

# TODO: есть возможность посылать удаление одного проекта много раз с ответом 200
# Нужно поправить это в БД!!!!
@app.post("/projectdelete")
async def project_delete(request: ProjectDelete, username: str = Depends(jwt_GetUsername)):
    success = db_ProjectDelete(username, request.projectname)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")
    






# def db_ProjectUpdate(username : str, projectname : str, new_projectname : str, new_description : str) -> bool:

class ProjectUpdate(BaseModel):
    projectname : str
    new_projectname : str
    new_description : str

@app.post("/projectupdate")
async def project_update(request: ProjectUpdate, username: str = Depends(jwt_GetUsername)):
    success = db_ProjectUpdate(username, request.projectname, request.new_projectname, request.new_description)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")
    



# def db_ProjectPublish(username : str, projectname : str) -> bool:

class ProjectPublish(BaseModel):
    projectname : str

@app.post("/projectpublish")
async def project_publish(request: ProjectPublish, username: str = Depends(jwt_GetUsername)):
    success = db_ProjectPublish(username, request.projectname)
    if success:
        return {"status": "success", "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400, detail="Failed to update profile")
    






# def db_ProjectCopy(username : str, projectname : str, new_projectname : str) -> bool:

class ProjectCopy(BaseModel):
    projectname : str
    new_projectname: str

@app.post("/projectcopy")
async def project_copy(request: ProjectCopy,
                       username: str = Depends(jwt_GetUsername)):
    success = db_ProjectCopy(username,
                             request.projectname,
                             request.new_projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")
    




class ProjectGetRequest(BaseModel):
    username: str

@app.get("/projectgetbyuser")
async def get_project_by_user(request: ProjectGetRequest,
                              username: str = Depends(jwt_GetUsername)):
    try:
        result = db_ProjectGetByUser(request.username,
                                       username)
        
        if not result:
            raise HTTPException(status_code=404, detail="No projects found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")



# def db_ProjectGetAllSortedByLikes(username: str, desc: bool) -> List[Dict[str, Any]]:
# def db_ProjectGetAllSortedByDate(username: str, desc: bool) -> List[Dict[str, Any]]:

class ProjectGetAll(BaseModel):
    # sort_by should be
    # DATE or LIKE
    sort_by: str
    desc: bool


@app.get("/projectgetall")
async def get_project_all(request: ProjectGetAll, username: str = Depends(jwt_GetUsername)):
    if request.sort_by == "DATE":
        sort_by_date = True
    elif request.sort_by == "LIKE":
        sort_by_date = False
    else:
        raise HTTPException(status_code=400, detail="Bad Request")

    try:
        if sort_by_date:
            result = db_ProjectGetAllSortedByDate(username, request.desc)
        else:
            result = db_ProjectGetAllSortedByLikes(username, request.desc)
        
        if not result:
            raise HTTPException(status_code=404, detail="No projects found")
        
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")