package controllers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	verify "github.com/rolthund/bidwars/license"
	"github.com/rolthund/bidwars/models"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func SearchContractorByTrade() gin.HandlerFunc {
	return func(c *gin.Context) {
		var searchcontractor []models.Contractor
		queryParam := c.Query("trade")
		if queryParam == "" {
			log.Println("query is empty")
			c.Header("Content-Type", "application/json")
			c.JSON(http.StatusNotFound, gin.H{"Error": "Invalid Search Index"})
			c.Abort()
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		searchquerydb, err := ContractorCollection.Find(ctx, bson.M{"trade": bson.M{"$regex": queryParam}})
		if err != nil {
			c.IndentedJSON(404, "something went wrong in fetching the dbquery")
			return
		}
		err = searchquerydb.All(ctx, &searchcontractor)
		if err != nil {
			log.Println(err)
			c.IndentedJSON(400, "invalid")
			return
		}
		defer searchquerydb.Close(ctx)
		if err := searchquerydb.Err(); err != nil {
			log.Println(err)
			c.IndentedJSON(400, "invalid request")
			return
		}
		defer cancel()
		c.IndentedJSON(200, searchcontractor)
	}

}

func SearchContractorByName() gin.HandlerFunc {
	return func(c *gin.Context) {
		var searchcontractor []models.Contractor
		queryParam := c.Query("name")
		if queryParam == "" {
			log.Println("query is empty")
			c.Header("Content-Type", "application/json")
			c.JSON(http.StatusNotFound, gin.H{"Error": "Invalid Search Index"})
			c.Abort()
			return
		}
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		searchquerydb, err := ContractorCollection.Find(ctx, bson.M{"name": bson.M{"$regex": queryParam}})
		if err != nil {
			c.IndentedJSON(404, "something went wrong in fetching the dbquery")
			return
		}
		err = searchquerydb.All(ctx, &searchcontractor)
		if err != nil {
			log.Println(err)
			c.IndentedJSON(400, "invalid")
			return
		}
		defer searchquerydb.Close(ctx)
		if err := searchquerydb.Err(); err != nil {
			log.Println(err)
			c.IndentedJSON(400, "invalid request")
			return
		}
		defer cancel()
		c.IndentedJSON(200, searchcontractor)
	}
}

func ShowContractors() gin.HandlerFunc {
	return func(c *gin.Context) {
		var contractorlist []models.Contractor
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		cursor, err := ContractorCollection.Find(ctx, bson.D{{}})
		if err != nil {
			c.IndentedJSON(http.StatusInternalServerError, "Something went wront with displaying all contractors")
			return
		}
		err = cursor.All(ctx, &contractorlist)
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
		c.IndentedJSON(200, contractorlist)
	}
}

func ShowMyContractors() gin.HandlerFunc {
	return func(c *gin.Context) {

		builder_ID := c.Param("id")
		builderID, _ := primitive.ObjectIDFromHex(builder_ID)

		// Find contractors associated with the specified builder
		var builderContractors []models.BuilderContractor
		filter := bson.M{"builder_id": builderID}
		cursor, err := UserContractorCollection.Find(context.Background(), filter)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving contractors"})
			return
		}
		defer cursor.Close(context.Background())
		if err := cursor.All(context.Background(), &builderContractors); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error processing contractors"})
			return
		}

		// Collect contractor IDs
		contractorIDs := make([]primitive.ObjectID, len(builderContractors))
		for i, bc := range builderContractors {
			contractorIDs[i] = bc.ContractorID
		}

		// Find contractors using the collected IDs
		var contractors []models.Contractor
		contractorFilter := bson.M{"_id": bson.M{"$in": contractorIDs}}
		cursor, err = ContractorCollection.Find(context.Background(), contractorFilter)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error retrieving contractors"})
			return
		}
		defer cursor.Close(context.Background())
		if err := cursor.All(context.Background(), &contractors); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Error processing contractors"})
			return
		}

		c.JSON(http.StatusOK, contractors)
	}
}

func AddToContractorsList() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		builder_ID := c.Param("id")
		contractor_ID := c.Query("contractor_id")

		builderID, _ := primitive.ObjectIDFromHex(builder_ID)
		contractorID, _ := primitive.ObjectIDFromHex(contractor_ID)

		newBuilderContractor := models.BuilderContractor{
			ContractorID: contractorID,
			BuilderID:    builderID,
		}

		_, err := UserContractorCollection.InsertOne(ctx, newBuilderContractor)
		if err != nil {
			c.IndentedJSON(http.StatusInternalServerError, "Something went wront with adding contractor to the list")
			return
		}

		c.IndentedJSON(200, "Successfully Added to the contractor list")
	}
}

func RemoveFromContractorsList() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		builderID := c.Query("_id")
		contractorID := c.Query("contractor_id")

		filter := bson.M{
			"builder_id":    builderID,
			"contractor_id": contractorID,
		}

		_, err := UserContractorCollection.DeleteOne(ctx, filter)
		if err != nil {
			c.IndentedJSON(http.StatusInternalServerError, "Something went wront with deleting contractor from the list")
			return
		}

		c.IndentedJSON(200, "Successfully deleted contractor from the list")
	}
}

func SortByRating() gin.HandlerFunc {
	return func(c *gin.Context) {

	}
}

func LeaveReview() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var review models.Review

		builder_ID := c.Param("id")
		builderID, _ := primitive.ObjectIDFromHex(builder_ID)

		contractor_ID := c.Param("contractor_id")
		contractorID, _ := primitive.ObjectIDFromHex(contractor_ID)

		if err := c.BindJSON(&review); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Error binding review"})
			return
		}

		review.Review_ID = primitive.NewObjectID()
		review.Builder_ID = builderID
		review.Contractor_ID = contractorID

		_, inserterr := reviewCollection.InsertOne(ctx, review)
		if inserterr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "error adding new review"})
			return
		}
		defer cancel()
		c.JSON(http.StatusCreated, "Review successfully added")
	}
}

func ShowContractorsReviews() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		contractor_ID := c.Param("contractor_id")
		contractorID, err := primitive.ObjectIDFromHex(contractor_ID)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid contractor ID format"})
			return
		}

		var reviews []models.Review

		filter := bson.M{"contractor_id": contractorID}

		cursor, err := reviewCollection.Find(ctx, filter)
		if err != nil {
			c.IndentedJSON(http.StatusInternalServerError, "Something went wront with displaying contractors reviews")
			return
		}

		err = cursor.All(ctx, &reviews)
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
		c.IndentedJSON(200, reviews)
	}
}

func ContractorViewerAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		var contractor models.Contractor
		defer cancel()
		if err := c.BindJSON(&contractor); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		contractor.Contractor_ID = primitive.NewObjectID()
		contractor.Reviews = make([]models.Review, 0)
		contractor.License = models.License{}
		contractor.License.InsuranceExpired = true
		contractor.License.LicenseExpired = true
		_, anyerr := ContractorCollection.InsertOne(ctx, contractor)
		if anyerr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Not Created"})
			return
		}
		defer cancel()
		c.JSON(http.StatusOK, "Successfully added our Contractor Admin!!")
	}
}

func VerifyContrctorsLicense() gin.HandlerFunc {
	return func(c *gin.Context) {

		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()

		var contractor models.Contractor

		contractor_ID := c.Param("contractor_id")
		contractorID, _ := primitive.ObjectIDFromHex(contractor_ID)

		err := ContractorCollection.FindOne(ctx, bson.M{"_id": contractorID}).Decode(&contractor)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to find contractor"})
			return
		}
		defer cancel()

		isValid, err := verify.VerifyLicenseInfo(contractor.License)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal Server Error"})
			return
		}

		if !isValid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid license information"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "License verified successfully!"})
	}
}

func UpdateContractorsLicense() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var contractor models.Contractor

		now := time.Now()
		today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)

		contractor_ID := c.Param("contractor_id")
		contractorID, _ := primitive.ObjectIDFromHex(contractor_ID)

		err := ContractorCollection.FindOne(ctx, bson.M{"_id": contractorID}).Decode(&contractor)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to find contractor"})
			return
		}
		defer cancel()

		contractor.License.LastVerifiedDate = today

		filter := bson.M{"_id": contractorID}

		update := bson.M{
			"$set": bson.M{
				"license": contractor.License,
			},
		}

		_, err = ContractorCollection.UpdateOne(ctx, filter, update)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update contractor"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "License updated successfully"})
	}
}
