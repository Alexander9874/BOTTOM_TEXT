from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import HTMLResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Security
from pydantic import BaseModel
from typing import List
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.background import BackgroundScheduler
from contextlib import asynccontextmanager


from db import *


# JWT |>

from jose import JWTError, jwt
import time


SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 120


def jwt_CreateToken(data: dict,
                    expires_delta: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    to_encode = data.copy()
    to_encode.update({"exp": time.time() + expires_delta * 60})
    encoded_jwt = jwt.encode(to_encode,
                             SECRET_KEY,
                             algorithm=ALGORITHM)
    return encoded_jwt


security = HTTPBearer()


def jwt_VerifyToken(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    try:
        if db_IsTokenRevoked(token):
            raise HTTPException(status_code=401,
                                detail="Token has been revoked")

        payload = jwt.decode(token,
                             SECRET_KEY,
                             algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(status_code=401,
                            detail="Invalid or expired token")


def jwt_GetUsername(credentials: HTTPAuthorizationCredentials = Security(security)):
    token = credentials.credentials
    try:
        if db_IsTokenRevoked(token):
            raise HTTPException(status_code=401,
                                detail="Token has been revoked")
        
        payload = jwt.decode(token, SECRET_KEY,
                             algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401,
                                detail="Invalid token payload")
        return username
    except JWTError:
        raise HTTPException(status_code=401,
                            detail="Invalid or expired token")

# <| END JWT


# API |>

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

class api_Param_req(BaseModel):
    projectname : str
    colors_num : int
    torus_mode : bool
    blue_death_conditions : List[int]
    blue_birth_conditions : List[int]
    blue_death_conditions_other : List[int]
    blue_birth_conditions_other : List[int]
    green_death_conditions : List[int]
    green_birth_conditions : List[int]
    green_death_conditions_other : List[int]
    green_birth_conditions_other : List[int]
    violet_death_conditions : List[int]
    violet_birth_conditions : List[int]
    violet_death_conditions_other : List[int]
    violet_birth_conditions_other : List[int]
    grid : List[int]

@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler()
    scheduler.add_job(db_CleanDeletedProjects, 'interval', hours=1) # 24 h mb
    scheduler.add_job(db_CleanRevokedToken, 'interval', minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    scheduler.start()
    
    print("Scheduler started.")
    try:
        yield
    finally:
        scheduler.shutdown(wait=False)
        print("Scheduler stopped.")


app = FastAPI(lifespan=lifespan)

origins = [
    "http://localhost:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", response_class=HTMLResponse)
async def api_GetRoot():
    with open("index.html", "r",
              encoding="utf-8") as f:
        return f.read()


@app.get("/protected",
         response_class=HTMLResponse)
async def api_GetProtected(payload: dict = Depends(jwt_VerifyToken)):
    with open("protected.html",
              "r",
              encoding="utf-8") as f:
        return f.read()


@app.post("/signup")
async def api_Signup(request: api_UserPassword_req):
    if db_Signup(request.username,
                 request.password):
        return {"detail": "Registration successful"}
    else:
        raise HTTPException(status_code=400,
                            detail="Registration failed")


@app.post("/login")
async def api_Login(data: api_UserPassword_req):
    if db_Login(data.username,
                data.password):
        token = jwt_CreateToken({"sub": data.username})
        return {"access_token": token,
                "token_type": "bearer"}
    raise HTTPException(status_code=401,
                        detail="Invalid username or password")


@app.post("/logout")
async def api_Logout(credentials: HTTPAuthorizationCredentials = Security(security),
                     payload: dict = Depends(jwt_VerifyToken)):
    token = credentials.credentials
    db_RevokeToken(token)
    return {"detail": "Logout successful. Token revoked."}


@app.post("/UpdateAuboutMe")
async def api_UpdateAboutMe(request: api_AboutMe_req,
                            username: str = Depends(jwt_GetUsername)):
    success = db_UpdateAboutMe(username,
                               request.about_me)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.get("/GetUserInfo")
async def api_GetUserInfo(username: str = Depends(jwt_GetUsername)):
    try:
        result = db_GetUserInfo(username)

        if not result:
            raise HTTPException(status_code=404,
                                detail="User not found")
        
        return {"status": "success",
                "data": result}
    except Exception as e:
        raise HTTPException(status_code=500,
                            detail=f"Internal server error: {e}")


@app.post("/CreateProject")
async def api_CreateProject(request: api_ProjectnameDescription_req,
                            username: str = Depends(jwt_GetUsername)):
    success = db_CreateProject(username,
                               request.projectname,
                               request.description)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.post("/DeleteProject")
async def api_DeleteProject(request: api_Projectname_req,
                            username: str = Depends(jwt_GetUsername)):
    success = db_DeleteProject(username,
                               request.projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.post("/UpdateProject")
async def api_UpdateProject(request: api_NewProjectnameDescription_req,
                            username: str = Depends(jwt_GetUsername)):
    success = db_UpdateProject(username, request.projectname,
                               request.new_projectname,
                               request.new_description)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


@app.post("/PublishProject")
async def api_PublishProject(request: api_Projectname_req,
                             username: str = Depends(jwt_GetUsername)):
    success = db_PublishProject(username,
                                request.projectname)
    if success:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update profile")


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
async def api_GetProjectsByUser(username: str,
                                username_caller: str = Depends(jwt_GetUsername)):
    try:
        result = db_GetProjectsByUser(username, username_caller)
    except Exception as e:
        print("Error occurred during database query")
        raise HTTPException(status_code=500,
                            detail=f"Internal server error: {e}")

    if not result:
        raise HTTPException(status_code=404,
                            detail="No projects found")
        
    return {"status": "success",
            "data": result}


@app.get("/GetAllProjects")
async def api_GetAllProjects(sort_by: str,
                             desc: bool,
                             username: str = Depends(jwt_GetUsername)):
    # Проверка параметра sort_by
    if sort_by.upper() == "DATE":
        sort_by_date = True
    elif sort_by.upper() == "LIKE":
        sort_by_date = False
    else:
        raise HTTPException(status_code=400, detail="Invalid sort_by parameter. Use 'DATE' or 'LIKE'.")

    try:
        if sort_by_date:
            result = db_GetAllProjectsSortedByDate(username, desc)
        else:
            result = db_GetAllProjectsSortedByLikes(username, desc)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")
    if not result:
        raise HTTPException(status_code=404, detail="No projects found")
    
    return {"status": "success", "data": result}


@app.post("/UpdateParam")
async def api_UpdateParam(request: api_Param_req, 
                          username: str = Depends(jwt_GetUsername)
):
    result = db_UpdateParam(username=username,
                            project_name=request.projectname,
                            colors_num=request.colors_num,
                            torus_mode=request.torus_mode,
                            blue_death_conditions=request.blue_death_conditions,
                            blue_birth_conditions=request.blue_birth_conditions,
                            blue_death_conditions_other=request.blue_death_conditions_other,
                            blue_birth_conditions_other=request.blue_birth_conditions_other,
                            green_death_conditions=request.green_death_conditions,
                            green_birth_conditions=request.green_birth_conditions,
                            green_death_conditions_other=request.green_death_conditions_other,
                            green_birth_conditions_other=request.green_birth_conditions_other,
                            violet_death_conditions=request.violet_death_conditions,
                            violet_birth_conditions=request.violet_birth_conditions,
                            violet_death_conditions_other=request.violet_death_conditions_other,
                            violet_birth_conditions_other=request.violet_birth_conditions_other,
                            grid=request.grid)
    
    if result:
        return {"status": "success",
                "message": "Profile updated successfully"}
    else:
        raise HTTPException(status_code=400,
                            detail="Failed to update parameters")


@app.get("/GetParam")
async def api_GetParam(projectname: str,
                       username: str = Depends(jwt_GetUsername),):
    try:
        # Вызов функции базы данных
        result = db_GetParam(username, projectname)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")
    
    if not result:
        raise HTTPException(status_code=404, detail="No projects found")
    return {"status": "success", "data": result}


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
    

@app.get("/GetProjectInfo")
async def api_GetProjectInfo(projectname: str,
                             username: str = Depends(jwt_GetUsername),):
    try:
        result = db_GetProjectInfo(username, projectname)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")
    
    if not result:
        raise HTTPException(status_code=404, detail="No projects found")
    return {"status": "success", "data": result}
