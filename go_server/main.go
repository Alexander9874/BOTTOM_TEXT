package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jackc/pgx/v5"
)

func loadHTML(w http.ResponseWriter, r *http.Request, fileName string) {
	http.ServeFile(w, r, fileName)
}

func authHandler(w http.ResponseWriter, r *http.Request) {
	loadHTML(w, r, "auth.html")
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	loadHTML(w, r, "home.html")
}

var db *pgx.Conn

// Секретный ключ для подписи JWT
var jwtKey = []byte("my_secret_key")

// Структура для хранения JWT claims
type Claims struct {
	Username string `json:"username"`
	jwt.RegisteredClaims
}

// Подключение к базе данных PostgreSQL
func initDB() {
	var err error
	dsn := "postgres://alexander:PGpass@localhost:5432/bottom_text"
	db, err = pgx.Connect(context.Background(), dsn)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Connected to PostgreSQL")
}

// Хендлер для авторизации пользователя с выдачей JWT
func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username == "" || password == "" {
		http.Error(w, "Username and password are required", http.StatusBadRequest)
		return
	}

	// Проверяем пользователя через функцию check_user_password
	var result int
	err := db.QueryRow(context.Background(), "SELECT check_user_password($1, $2)", username, password).Scan(&result)
	if err != nil || result != 0 {
		http.Error(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	// Создаем JWT токен
	expirationTime := time.Now().Add(5 * time.Minute)
	claims := &Claims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		http.Error(w, "Error creating JWT token", http.StatusInternalServerError)
		return
	}

	// Возвращаем токен пользователю
	http.SetCookie(w, &http.Cookie{
		Name:    "token",
		Value:   tokenString,
		Expires: expirationTime,
	})

	fmt.Fprintln(w, "Login successful")
}

// Middleware для проверки JWT токена
func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Получаем токен из cookie
		cookie, err := r.Cookie("token")
		if err != nil {
			if err == http.ErrNoCookie {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}
			http.Error(w, "Bad request", http.StatusBadRequest)
			return
		}

		// Проверяем токен
		tokenStr := cookie.Value
		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})

		if err != nil || !token.Valid {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Если все ок, передаем управление следующему хендлеру
		next.ServeHTTP(w, r)
	})
}

func signupHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	username := r.FormValue("username")
	password := r.FormValue("password")

	if username == "" || password == "" {
		http.Error(w, "Username and password are required", http.StatusBadRequest)
		return
	}

	var result int
	err := db.QueryRow(context.Background(), "SELECT create_user($1, $2)", username, password).Scan(&result)
	if err != nil || result != 0 {
		http.Error(w, "Error creating user", http.StatusInternalServerError)
		return
	}

	fmt.Fprintln(w, "Signup successful")
}

func main() {
	initDB()
	defer db.Close(context.Background())

	http.HandleFunc("/auth", authHandler)

	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/signup", signupHandler)

	//	http.HandleFunc("/home", homeHandler)
	http.Handle("/home", authMiddleware(http.HandlerFunc(homeHandler)))

	// Запуск сервера
	fmt.Println("Server started at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
