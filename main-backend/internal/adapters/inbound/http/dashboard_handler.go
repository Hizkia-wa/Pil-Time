package http

import (
	"backend/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
)

type DashboardHandler struct {
	dashboardUsecase *usecase.DashboardUsecase
}

func NewDashboardHandler(u *usecase.DashboardUsecase) *DashboardHandler {
	return &DashboardHandler{u}
}

// GetDashboard menangani HTTP request untuk mendapatkan statistik dashboard
func (h *DashboardHandler) GetDashboard(c *gin.Context) {
	resp, err := h.dashboardUsecase.GetDashboard()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "DASHBOARD_ERROR",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}
