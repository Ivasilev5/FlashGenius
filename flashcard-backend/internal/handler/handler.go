package handler

import "github.com/gofiber/fiber/v2"

// RegisterRoutes wires all HTTP endpoints. Concrete handlers will be
// implemented as the corresponding services and repositories are ready.
func RegisterRoutes(app *fiber.App) {
	api := app.Group("/api/v1")

	_ = api
	// TODO: add auth, decks, cards, study, and AI routes.
}

