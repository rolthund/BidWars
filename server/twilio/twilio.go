package twilio

import (
	"fmt"
	"log"
	"os"

	"github.com/twilio/twilio-go"
	openapi "github.com/twilio/twilio-go/rest/verify/v2"

	"github.com/joho/godotenv"
)

func SendOtp(to string) error {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
	var TWILIO_ACCOUNT_SID string = os.Getenv("TWILIO_ACCOUNT_SID")
	var TWILIO_AUTH_TOKEN string = os.Getenv("TWILIO_AUTH_TOKEN")
	var VERIFY_SERVICE_SID string = os.Getenv("VERIFY_SERVICE_SID")
	var client *twilio.RestClient = twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: TWILIO_ACCOUNT_SID,
		Password: TWILIO_AUTH_TOKEN,
	})

	params := &openapi.CreateVerificationParams{}
	params.SetTo(to)
	params.SetChannel("sms")

	resp, err := client.VerifyV2.CreateVerification(VERIFY_SERVICE_SID, params)

	if err != nil {
		fmt.Println(err.Error())
		return err
	} else {
		fmt.Printf("Sent verification '%s'\n", *resp.Sid)
		return nil
	}
}

func CheckOtp(to string, code string) (bool, error) {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
	var TWILIO_ACCOUNT_SID string = os.Getenv("TWILIO_ACCOUNT_SID")
	var TWILIO_AUTH_TOKEN string = os.Getenv("TWILIO_AUTH_TOKEN")
	var VERIFY_SERVICE_SID string = os.Getenv("VERIFY_SERVICE_SID")
	var client *twilio.RestClient = twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: TWILIO_ACCOUNT_SID,
		Password: TWILIO_AUTH_TOKEN,
	})

	params := &openapi.CreateVerificationCheckParams{}
	params.SetTo(to)
	params.SetCode(code)

	resp, err := client.VerifyV2.CreateVerificationCheck(VERIFY_SERVICE_SID, params)

	if err != nil {
		fmt.Println(err.Error())
		return false, err
	}
	return *resp.Status == "approved", nil
}
