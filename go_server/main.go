package main

import (
	"fmt"
	"net/http"
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

func main() {
	http.HandleFunc("/auth", authHandler)
	http.HandleFunc("/home", homeHandler)

	fmt.Println("Сервер запущен на http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
