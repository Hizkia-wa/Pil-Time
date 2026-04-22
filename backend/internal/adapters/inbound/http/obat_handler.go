package http

import (
    "backend/internal/dto"
    "backend/internal/usecase"
    "fmt" // <--- TAMBAHKAN INI
    "net/http"
    "os"
    "path/filepath"
    "strconv"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

type ObatHandler struct {
	usecase *usecase.ObatUsecase
}

func NewObatHandler(u *usecase.ObatUsecase) *ObatHandler {
	return &ObatHandler{usecase: u}
}

// GetAll mendapatkan semua obat
func (h *ObatHandler) GetAll(c *gin.Context) {
	obats, err := h.usecase.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{
			Error:   "FETCH_ERROR",
			Message: err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": obats})
}

// Create menangani FormData (Text + File)
func (h *ObatHandler) Create(c *gin.Context) {
    var req dto.CreateObatDTO

    // 1. Bind data teks terlebih dahulu
    if err := c.ShouldBind(&req); err != nil {
        c.JSON(http.StatusBadRequest, dto.ErrorResponse{
            Error: "VALIDATION_ERROR", Message: err.Error(),
        })
        return
    }

    // 2. Ambil file gambar (Key: gambar_file sesuai di Vue kamu)
    file, err := c.FormFile("gambar_file")
    if err == nil {
        uploadDir := "public/uploads"
        os.MkdirAll(uploadDir, os.ModePerm)

        filename := uuid.New().String() + filepath.Ext(file.Filename)
        filePath := filepath.Join(uploadDir, filename)

        if err := c.SaveUploadedFile(file, filePath); err == nil {
            // SETELAH Save sukses, baru masukkan path ke req.Gambar
            req.Gambar = "/uploads/" + filename
        }
    } else {
        fmt.Println("Info: Tidak ada file gambar yang diupload:", err)
    }

    // 3. Simpan ke Database via Usecase
    resp, err := h.usecase.Create(&req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "CREATE_ERROR", Message: err.Error(),
		})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": resp})
}

// Update data obat
func (h *ObatHandler) Update(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var req dto.UpdateObatDTO

	if err := c.ShouldBind(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "VALIDATION_ERROR", Message: err.Error(),
		})
		return
	}

	file, err := c.FormFile("gambar_file")
	if err == nil {
		uploadDir := "public/uploads"
		os.MkdirAll(uploadDir, os.ModePerm)
		filename := uuid.New().String() + filepath.Ext(file.Filename)
		filePath := filepath.Join(uploadDir, filename)
		c.SaveUploadedFile(file, filePath)
		req.Gambar = "/uploads/" + filename
	}

	resp, err := h.usecase.Update(id, &req)
	if err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "UPDATE_ERROR", Message: err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": resp})
}

// GetByID mendapatkan satu obat
func (h *ObatHandler) GetByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	obat, err := h.usecase.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{
			Error: "NOT_FOUND", Message: err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": obat})
}

// Delete obat
func (h *ObatHandler) Delete(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := h.usecase.Delete(id); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{
			Error: "DELETE_ERROR", Message: err.Error(),
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Obat berhasil dihapus"})
}