package license

import (
	"context"
	"errors"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/chromedp/chromedp"
	"github.com/rolthund/bidwars/models"
	"github.com/rolthund/bidwars/twilio"
)

var PhoneNumber string

func checkLicense(UBI string, insurance string, license string, bond string) (bool, error) {
	var isValid = false
	//we will use a phone nub=mber verification from lni site and no longer need to verify company name
	url := fmt.Sprintf("https://secure.lni.wa.gov/verify/Detail.aspx?UBI=%s&LIC=%s&SAW=", UBI, license)

	ctx, cancel := chromedp.NewContext(context.Background())
	defer cancel()

	timeoutCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var scrapedLicense string
	var scrapedInsurance string
	var scrapedBond string
	var scrapedName string
	var insuranceExpDate string
	var licenseExpDate string
	var isInsuranceExpired bool
	var isLicenseExpired bool

	err := chromedp.Run(timeoutCtx,
		chromedp.Navigate(url),
		chromedp.WaitReady("//*[@id='LicenseNumber']", chromedp.BySearch),
		chromedp.Text("//*[@id='LicenseNumber']", &scrapedLicense, chromedp.BySearch),
		chromedp.WaitReady("//*[@id='BondAccountNumber']", chromedp.BySearch),
		chromedp.Text("//*[@id='BondAccountNumber']", &scrapedBond, chromedp.BySearch),
		chromedp.WaitReady("//*[@id='InsurancesAccountId']", chromedp.BySearch),
		chromedp.Text("//*[@id='PhoneNumber']", &PhoneNumber, chromedp.BySearch),
		chromedp.Text("//*[@id='InsurancesAccountId']", &scrapedInsurance, chromedp.BySearch),
		chromedp.Text("//*[@id='BusinessName']", &scrapedName, chromedp.BySearch),
		chromedp.Text("//*[@id='ExpirationDate']", &licenseExpDate, chromedp.BySearch),
		chromedp.Text("//*[@id='InsurancesExpirationDate']", &insuranceExpDate, chromedp.BySearch),
	)
	if err != nil {
		log.Printf("Failed to retrieve the element text: %v", err)
	}

	log.Printf(PhoneNumber)
	//Temporary line for testing on my phone
	PhoneNumber = "206-730-6166"

	layout := "01/02/2006"
	licenseDate, err := time.Parse(layout, licenseExpDate)
	insuranceDate, err := time.Parse(layout, insuranceExpDate)

	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)

	fmt.Println(today)

	isLicenseExpired = licenseDate.Before(today)
	isInsuranceExpired = insuranceDate.Before(today)

	if scrapedLicense == "" {
		err := errors.New("could not scrape the information")
		return false, err
	}

	if strings.ToLower(license) == strings.ToLower(scrapedLicense) && !isInsuranceExpired && !isLicenseExpired {
		isValid = true
		PhoneNumber = "+1" + strings.ReplaceAll(PhoneNumber, "-", "")
		twilio.SendOtp(PhoneNumber)
	}

	return isValid, nil

}

// Somethimes scraping the page returns empty strings and we need to run checkLicense several times
// but in order to not create infinite cycle we need to limit the function calls
func VerifyLicenseInfo(license models.License) (bool, error) {

	var isVerified bool
	var err error
	loopCycle := 0
	for {
		isVerified, err = checkLicense(*license.UBI_number, *license.Insurance, *license.License_number, *license.Bond)
		if err == nil {
			break
		}
		if loopCycle > 3 {
			break
		}
		loopCycle++
	}
	return isVerified, nil
}
