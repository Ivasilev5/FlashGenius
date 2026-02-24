package domain

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey"`
	Email        string    `gorm:"unique;not null"`
	Username     string    `gorm:"not null"`
	PasswordHash string    `gorm:"not null"`
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

type Deck struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID      uuid.UUID `gorm:"type:uuid;not null"`
	Title       string    `gorm:"not null"`
	Description string
	IsPublic    bool      `gorm:"default:false"`
	CardCount   int       `gorm:"-"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
	Cards       []Card `gorm:"foreignKey:DeckID"`
}

type Card struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey"`
	DeckID        uuid.UUID `gorm:"type:uuid;not null"`
	Question      string    `gorm:"not null"`
	Answer        string    `gorm:"not null"`
	QuestionImage *string
	AnswerImage   *string
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

type CardProgress struct {
	ID             uuid.UUID  `gorm:"type:uuid;primaryKey"`
	UserID         uuid.UUID  `gorm:"type:uuid;not null"`
	CardID         uuid.UUID  `gorm:"type:uuid;not null"`
	Difficulty     string
	EaseFactor     float64    `gorm:"default:2.5"`
	Interval       int        `gorm:"default:1"`
	Repetitions    int        `gorm:"default:0"`
	NextReviewAt   time.Time
	LastReviewedAt *time.Time
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

