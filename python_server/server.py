from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Security

from jose import JWTError, jwt

from pydantic import BaseModel
import psycopg2
import time

from psycopg2.extras import RealDictCursor

# Конфигурация
SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 5

# DATABASE |>

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
def db_UserSignUp(username: str, password: str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT create_user(%s, %s)", (username, password))
        result = cur.fetchone()[0]
        cur.close()
        conn.commit()
        conn.close()
        return result == 0
    except Exception as e:
        print(f"Error: {e}")
        return False

# Логин пользователя
def db_UserLogIn(username: str, password: str) -> bool:
    try:
        conn = db_GetConnection()
        cur = conn.cursor()
        cur.execute("SELECT check_user_password(%s, %s)", (username, password))
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
        cur.execute("INSERT INTO RevokedTokens (token_text) VALUES (%s) ON CONFLICT DO NOTHING", (token,))
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
        cur.execute("SELECT COUNT(*) FROM RevokedTokens WHERE token_text = %s", (token,))
        result = cur.fetchone()[0]
        cur.close()
        conn.close()
        return result > 0
    except Exception as e:
        print(f"Error checking token: {e}")
        return True

# <| END DATABASE

# JWT |>

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
        return {"message": "Registration successful"}
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
    return {"message": "Logout successful. Token revoked."}