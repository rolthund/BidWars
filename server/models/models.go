package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Builder struct {
	ID            primitive.ObjectID   `json:"_id" bson:"_id"`
	Name          *string              `json:"name"                       validate:"required,min=2,max=30"`
	Password      *string              `json:"password"                   validate:"required,min=6"`
	Email         *string              `json:"email"                      validate:"email,required"`
	Phone         *string              `json:"phone"                      validate:"required"`
	Projects      []primitive.ObjectID `json:"project"`
	Created_At    time.Time            `json:"created_at"`
	Updated_At    time.Time            `json:"updated_at"`
	Token         *string              `json:"token"`
	Refresh_Token *string              `json:"refresh_token"`
	License       License              `json:"license" bson:"license"`
	User_ID       string               `bson:"user_id"`
}

type Contractor struct {
	Contractor_ID primitive.ObjectID `json:"_id" bson:"_id"`
	Name          *string            `json:"name" validate:"required,min=2,max=30"`
	Trade         *string            `json:"trade" validate:"required,min=2,max=30"`
	Avr_rating    float32            `json:"avr_rating"`
	Email         *string            `json:"email"`
	Phone         *string            `json:"phone"`
	Reviews       []Review           `json:"reviews" bson:"reviews"`
	License       License            `json:"license" bson:"license"`
}

type BuilderContractor struct {
	ContractorID primitive.ObjectID `bson:"contractor_id"`
	BuilderID    primitive.ObjectID `bson:"builder_id"`
}

type Project struct {
	Project_ID  primitive.ObjectID `json:"_id" bson:"_id"`
	Builder_ID  primitive.ObjectID `json:"builder_id" bson:"builder_id"`
	Description *string            `json:"description"`
	Name        *string            `json:"name"`
	Trade       *string            `json:"trade" validate:"required,min=2,max=30"`
	Location    *string            `json:"location"`
	Bidable     bool               `json:"bidable"`
	StartDate   time.Time          `json:"start_date"`
}

type Review struct {
	Review_ID     primitive.ObjectID `json:"_id" bson:"_id"`
	Contractor_ID primitive.ObjectID `json:"contractor_id" bson:"contractor_id"`
	Builder_ID    primitive.ObjectID `json:"builder_id" bson:"builder_id"`
	Rating        int                `json:"rating"`
	Description   *string            `json:"description"`
	Date          time.Time          `json:"date"`
}

type License struct {
	InsuranceExpired bool      `json:"isInsuranceExpired"`
	LicenseExpired   bool      `json:"isLicenseExpired"`
	UBI_number       *string   `json:"UBI_number"`
	License_number   *string   `json:"license_number"`
	Bond             *string   `json:"bond"`
	Insurance        *string   `json:"insurance"`
	LastVerifiedDate time.Time `json:"lastverified"`
}
