package controllers

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/rolthund/bidwars/database"
	verify "github.com/rolthund/bidwars/license"
	"github.com/rolthund/bidwars/models"
	"github.com/rolthund/bidwars/twilio"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"

	generate "github.com/rolthund/bidwars/tokens"
)

var ContractorCollection *mongo.Collection = database.ContractorData(database.Client, "contractors")
var UserCollection *mongo.Collection = database.BuilderData(database.Client, "builders")
var UserContractorCollection *mongo.Collection = database.BuilderContractorData(database.Client, "builder_contractor")
var ProjectCollection *mongo.Collection = database.ProjectData(database.Client, "projects")
var Validate = validator.New()

func HashPassword(password string) string {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	if err != nil {
		log.Panic(err)
	}
	return string(bytes)
}

func VerifyPassword(userpassword string, givenpassword string) (bool, string) {
	err := bcrypt.CompareHashAndPassword([]byte(givenpassword), []byte(userpassword))
	valid := true
	msg := ""
	if err != nil {
		msg = "Login Or Passowrd is Incorerct"
		valid = false
	}
	return valid, msg
}

func SignUp() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var user models.Builder
		if err := c.BindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		validationErr := Validate.Struct(user)
		if validationErr != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": validationErr})
			return
		}

		count, err := UserCollection.CountDocuments(ctx, bson.M{"email": user.Email})
		if err != nil {
			log.Panic(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err})
			return
		}
		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "User already exists, email is already in use"})
			return
		}
		count, err = UserCollection.CountDocuments(ctx, bson.M{"phone": user.Phone})
		defer cancel()
		if err != nil {
			log.Panic(err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": err})
			return
		}
		if count > 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Phone is already in use"})
			return
		}
		password := HashPassword(*user.Password)
		user.Password = &password

		user.Created_At, _ = time.Parse(time.RFC3339, time.Now().Format(time.RFC3339))
		user.Updated_At, _ = time.Parse(time.RFC3339, time.Now().Format(time.RFC3339))
		user.ID = primitive.NewObjectID()
		user.User_ID = user.ID.Hex()
		token, refreshtoken, _ := generate.TokenGenerator(*user.Email, *user.Name, user.User_ID)
		user.Token = &token
		user.Refresh_Token = &refreshtoken
		user.Projects = make([]primitive.ObjectID, 0)
		user.License = models.License{}
		_, inserterr := UserCollection.InsertOne(ctx, user)
		if inserterr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": inserterr.Error()})
			return
		}
		defer cancel()
		c.JSON(http.StatusCreated, "Successfully Signed Up!!")
	}
}

func Login() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var user models.Builder
		var founduser models.Builder
		if err := c.BindJSON(&user); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err})
			return
		}
		err := UserCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&founduser)
		defer cancel()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "login or password incorrect"})
			return
		}
		PasswordIsValid, msg := VerifyPassword(*user.Password, *founduser.Password)
		defer cancel()
		if !PasswordIsValid {
			c.JSON(http.StatusInternalServerError, gin.H{"error": msg})
			fmt.Println(msg)
			return
		}
		token, refreshToken, _ := generate.TokenGenerator(*founduser.Email, *founduser.Name, founduser.User_ID)
		defer cancel()
		generate.UpdateAllTokens(token, refreshToken, founduser.User_ID)
		c.JSON(http.StatusFound, founduser)

	}
}

func UpdateLicense() gin.HandlerFunc {
	return func(c *gin.Context) {
		var ctx, cancel = context.WithTimeout(context.Background(), 100*time.Second)
		defer cancel()
		var founduser models.Builder

		var updatedLicense models.License
		if err := c.BindJSON(&updatedLicense); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		userID := c.Param("id") // Assuming user_id is part of the URL path
		err := UserCollection.FindOne(ctx, bson.M{"user_id": userID}).Decode(&founduser)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to find user"})
			return
		}
		defer cancel()

		founduser.License = updatedLicense

		filter := bson.M{"user_id": userID}

		update := bson.M{
			"$set": bson.M{
				"license": founduser.License,
			},
		}

		_, err = UserCollection.UpdateOne(ctx, filter, update)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "License updated successfully"})
	}
}

func VerifyLicense() gin.HandlerFunc {
	return func(c *gin.Context) {

		var license models.License

		if err := c.BindJSON(&license); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		isValid, err := verify.VerifyLicenseInfo(license)
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

func VerifyPhoneNumber() gin.HandlerFunc {
	return func(c *gin.Context) {

		code := c.Query("code")
		isValid, err := twilio.CheckOtp(verify.PhoneNumber, code)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not verify number with twilio"})
			return
		}

		if !isValid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Code wasn recieved or was wrong"})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Phone verified successfully!"})
	}
}
