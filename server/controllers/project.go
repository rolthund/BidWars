package controllers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rolthund/bidwars/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Application struct {
	contractorCollection        *mongo.Collection
	builderColection            *mongo.Collection
	builderContractorCollection *mongo.Collection
	projectCollection           *mongo.Collection
}

func NewApplication(contractorCollection, builderColection, builderContractorCollection, projectCollection *mongo.Collection) *Application {
	return &Application{
		contractorCollection:        contractorCollection,
		builderColection:            builderColection,
		builderContractorCollection: builderContractorCollection,
		projectCollection:           projectCollection,
	}
}

func AddProject() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var project models.Project

		builder_ID := c.Param("id")
		builderID, _ := primitive.ObjectIDFromHex(builder_ID)

		if err := c.BindJSON(&project); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Error adding project"})
			return
		}

		project.Project_ID = primitive.NewObjectID()
		project.Builder_ID = builderID

		_, inserterr := ProjectCollection.InsertOne(ctx, project)
		if inserterr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "error adding new project"})
			return
		}
		defer cancel()
		c.JSON(http.StatusCreated, "Successfully created new project")

	}
}

func DeleteProjectByID() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		project_ID := c.Param("project_id")
		projectID, err := primitive.ObjectIDFromHex(project_ID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid project ID format"})
			return
		}

		filter := bson.M{"project_id": projectID}
		result, err := ProjectCollection.DeleteOne(ctx, filter)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error deleting the project"})
		}

		if result.DeletedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"message": "No project found with the specified ID"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Project deleted successfully"})
	}
}

func ShowAllProjects() gin.HandlerFunc {
	return func(c *gin.Context) {

		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var projectList []models.Project

		cursor, err := ProjectCollection.Find(ctx, bson.D{{}})
		if err != nil {
			c.IndentedJSON(http.StatusInternalServerError, "Something went wront with displaying projects")
			return
		}
		err = cursor.All(ctx, &projectList)
		if err != nil {
			log.Println(err)
			c.AbortWithStatus(http.StatusInternalServerError)
			return
		}
		defer cursor.Close(ctx)

		if err := cursor.Err(); err != nil {
			log.Println(err)
			c.IndentedJSON(400, "invalid")
			return
		}
		defer cancel()
		c.IndentedJSON(200, projectList)
	}
}

func UpdateProject() gin.HandlerFunc {
	return func(c *gin.Context) {

		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		project_id := c.Param("project_id")
		if project_id == "" {
			c.JSON(http.StatusNotFound, gin.H{"Error": "Wrong id provided"})
			return
		}

		projectID, err := primitive.ObjectIDFromHex(project_id)
		if err != nil {
			c.IndentedJSON(500, err)
		}

		var editproject models.Project
		if err := c.BindJSON(&editproject); err != nil {
			c.IndentedJSON(http.StatusBadRequest, err.Error())
			return
		}

		filter := bson.M{"project_id": projectID}
		update := bson.M{"$set": bson.M{
			"name":        editproject.Name,
			"description": editproject.Description,
			"trade":       editproject.Trade,
			"bidable":     editproject.Bidable,
			"start_date":  editproject.StartDate,
		}}

		result, err := ProjectCollection.UpdateOne(ctx, filter, update)
		if err != nil {
			c.IndentedJSON(500, "Error updating project")
		}

		if result.MatchedCount == 0 {
			c.JSON(http.StatusNotFound, gin.H{"error": "No project found with specified ID"})
		}
		ctx.Done()
		c.IndentedJSON(200, "Successfully updated the project")
	}
}

func (app *Application) ShowProjectByID() gin.HandlerFunc {
	return func(c *gin.Context) {

	}
}
