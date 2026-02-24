package config

import (
	"os"
	"time"
)

type Config struct {
	AppPort        string
	AppEnv         string
	DBHost         string
	DBPort         string
	DBName         string
	DBUser         string
	DBPassword     string
	RedisURL       string
	JWTAccessSecret  string
	JWTRefreshSecret string
	JWTAccessTTL     time.Duration
	JWTRefreshTTL    time.Duration
	OpenAIAPIKey   string
	OpenAIModel    string
	S3Endpoint     string
	S3Bucket       string
	S3AccessKey    string
	S3SecretKey    string
	S3UseSSL       bool
}

// Placeholder loader. Will be extended to use env parsing + validation.
func Load() *Config {
	return &Config{
		AppPort:        getEnv("APP_PORT", "8080"),
		AppEnv:         getEnv("APP_ENV", "development"),
		DBHost:         getEnv("DB_HOST", "localhost"),
		DBPort:         getEnv("DB_PORT", "5432"),
		DBName:         getEnv("DB_NAME", "flashcards"),
		DBUser:         getEnv("DB_USER", "postgres"),
		DBPassword:     getEnv("DB_PASSWORD", "secret"),
		RedisURL:       getEnv("REDIS_URL", "redis://localhost:6379"),
		JWTAccessSecret:  getEnv("JWT_ACCESS_SECRET", "your_secret"),
		JWTRefreshSecret: getEnv("JWT_REFRESH_SECRET", "your_refresh_secret"),
		OpenAIAPIKey:   getEnv("OPENAI_API_KEY", ""),
		OpenAIModel:    getEnv("OPENAI_MODEL", "gpt-4o"),
		S3Endpoint:     getEnv("S3_ENDPOINT", "localhost:9000"),
		S3Bucket:       getEnv("S3_BUCKET", "flashcards"),
		S3AccessKey:    getEnv("S3_ACCESS_KEY", "minioadmin"),
		S3SecretKey:    getEnv("S3_SECRET_KEY", "minioadmin"),
		S3UseSSL:       getEnv("S3_USE_SSL", "false") == "true",
	}
}

func getEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

