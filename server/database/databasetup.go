package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func DBSet() *mongo.Client {
	client, err := mongo.NewClient(options.Client().ApplyURI("${MONGODB_URL}"))
	if err != nil {
		log.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		log.Fatal(err)
	}

	err = client.Ping(context.TODO(), nil)
	if err != nil {
		log.Println("failed to connect to mongodb")
		return nil
	}
	fmt.Println("Successfully Connected to the mongodb")
	return client
}

var Client *mongo.Client = DBSet()

func ContractorData(client *mongo.Client, CollectionName string) *mongo.Collection {
	var collection *mongo.Collection = client.Database("Bidwars").Collection(CollectionName)
	return collection

}

func BuilderData(client *mongo.Client, CollectionName string) *mongo.Collection {
	var buildercollection *mongo.Collection = client.Database("Bidwars").Collection(CollectionName)
	return buildercollection
}

func BuilderContractorData(client *mongo.Client, CollectionName string) *mongo.Collection {
	var collection *mongo.Collection = client.Database("Bidwars").Collection(CollectionName)
	return collection
}

func ProjectData(client *mongo.Client, CollectionName string) *mongo.Collection {
	var projectcollection *mongo.Collection = client.Database("Bidwars").Collection(CollectionName)
	return projectcollection
}

func ReviewData(client *mongo.Client, CollectionName string) *mongo.Collection {
	var reviewCollection *mongo.Collection = client.Database("Bidwars").Collection(CollectionName)
	return reviewCollection
}
