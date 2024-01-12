package controllers

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestShowAllProjects(t *testing.T) {
	gin.SetMode(gin.TestMode)

	r := gin.Default()
	r.GET("http://localhost:8000/users/650a5929bffcf0800432c2f9/listmyprojects", ShowAllProjects())

	req, _ := http.NewRequest("GET", "/http://localhost:8000/users/650a5929bffcf0800432c2f9/listmyprojects", nil)
	w := httptest.NewRecorder()

	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status %d, but got %d", http.StatusOK, w.Code)
	}

	print(w)
}
