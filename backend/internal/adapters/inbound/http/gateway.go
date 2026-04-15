package http

import (
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Gateway untuk forward requests ke microservices
type Gateway struct {
	jadwalServiceURL string
}

func NewGateway(jadwalServiceURL string) *Gateway {
	return &Gateway{
		jadwalServiceURL: jadwalServiceURL,
	}
}

// ForwardJadwal forward request ke jadwal microservice
func (g *Gateway) ForwardJadwal(c *gin.Context) {
	// Build target URL - ubah /api/admin/jadwal menjadi /api/jadwal
	path := c.Request.URL.Path
	if len(path) > 17 {
		path = path[17:] // Skip "/api/admin/jadwal"
	} else {
		path = ""
	}

	targetURL := g.jadwalServiceURL + "/api/jadwal" + path
	if c.Request.URL.RawQuery != "" {
		targetURL += "?" + c.Request.URL.RawQuery
	}

	// Create new request
	req, err := http.NewRequest(c.Request.Method, targetURL, c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{
			"error": "Failed to create gateway request",
		})
		return
	}

	// Copy headers
	for key, values := range c.Request.Header {
		for _, value := range values {
			req.Header.Add(key, value)
		}
	}

	// Send request to jadwal service
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusBadGateway, gin.H{
			"error": "Failed to reach jadwal service",
		})
		return
	}
	defer resp.Body.Close()

	// Copy response headers
	for key, values := range resp.Header {
		for _, value := range values {
			c.Header(key, value)
		}
	}

	body, _ := io.ReadAll(resp.Body)
	c.Data(resp.StatusCode, resp.Header.Get("Content-Type"), body)
}
