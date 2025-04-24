package department

import (
	"github.com/syedomair/backend-k8/models"
)

// Repository interface
type Repository interface {
	GetAllDepartmentDB(limit int, offset int, orderby string, sort string) ([]*models.Department, string, error)
}
