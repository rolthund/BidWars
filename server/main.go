package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/rolthund/bidwars/controllers"
	"github.com/rolthund/bidwars/database"
	"github.com/rolthund/bidwars/routes"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	app := controllers.NewApplication(
		database.ContractorData(database.Client, "contractors"),
		database.BuilderData(database.Client, "builders"),
		database.BuilderContractorData(database.Client, "builder_contractor"),
		database.ProjectData(database.Client, "projects"))

	router := gin.New()

	userGroup := router.Group("/users/:id")
	//userGroup.Use(middleware.Authentication())
	routes.UserRoutes(userGroup)
	router.Use(gin.Logger())
	//router.Use(middleware.Authentication())
	router.POST("/users/signup", controllers.SignUp())
	router.POST("/users/login", controllers.Login())
	router.GET("/users/findprojectbyid", app.ShowProjectByID())
	router.GET("/listcontractors", controllers.ShowContractors())
	router.GET("/searchbyname", controllers.SearchContractorByName())
	router.GET("/searchbytrade", controllers.SearchContractorByTrade())
	router.GET("/listcontractorsreviews/:contractor_id", controllers.ShowContractorsReviews())
	router.GET("/getbuilderbyid/:id", controllers.GetBuilderByID())
	log.Fatal(router.Run(":" + port))

}
