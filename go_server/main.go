package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

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

func initDB() {
	var err error
	dsn := "postgres://XXXXX:XXXXX@localhost:5432/bottom_text"
	db, err = pgx.Connect(context.Background(), dsn)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("Connected to PostgreSQL")
}

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

	var result int
	err := db.QueryRow(context.Background(), "SELECT check_user_password($1, $2)", username, password).Scan(&result)
	if err != nil || result != 0 {
		http.Error(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	fmt.Fprintln(w, "Login successful")
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
	http.HandleFunc("/home", homeHandler)

	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/signup", signupHandler)

	fmt.Println("Server started at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
