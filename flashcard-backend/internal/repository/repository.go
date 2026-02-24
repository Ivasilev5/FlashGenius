package repository

import "gorm.io/gorm"

// Placeholders for repository interfaces and implementations.
// Detailed methods will be added alongside service and handler logic.

type UserRepository interface {
	// TODO: define user-related persistence methods
}

type DeckRepository interface {
	// TODO: define deck-related persistence methods
}

type CardRepository interface {
	// TODO: define card-related persistence methods
}

type CardProgressRepository interface {
	// TODO: define card progress-related persistence methods
}

type Repositories struct {
	DB *gorm.DB
}

func NewRepositories(db *gorm.DB) *Repositories {
	return &Repositories{DB: db}
}

