package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/rolthund/bidwars/controllers"
)

func UserRoutes(incomingRoutes *gin.RouterGroup) {
	incomingRoutes.POST("/addcontractor", controllers.ContractorViewerAdmin())
	incomingRoutes.POST("/addtomylist", controllers.AddToContractorsList())
	incomingRoutes.DELETE("/removefromlist", controllers.RemoveFromContractorsList())
	incomingRoutes.GET("/listmycontractors", controllers.ShowMyContractors())
	incomingRoutes.PUT("/updatelicense", controllers.UpdateLicense())
	incomingRoutes.POST("/verifylicense", controllers.VerifyLicense())
	incomingRoutes.POST("/verifyphone", controllers.VerifyPhoneNumber())
	incomingRoutes.GET("/listmyprojects", controllers.ShowAllProjects())
	incomingRoutes.POST("/addproject", controllers.AddProject())
	incomingRoutes.DELETE("deleteproject/:project_id", controllers.DeleteProjectByID())
	incomingRoutes.PUT("editproject/:project_id", controllers.UpdateProject())
	incomingRoutes.POST("leavereview/:contractor_id", controllers.LeaveReview())
	incomingRoutes.POST("/verifycontractorslicense/:contractor_id", controllers.VerifyContrctorsLicense())
	incomingRoutes.POST("/updatecontractorslicense/:contractor_id", controllers.UpdateContractorsLicense())
}
