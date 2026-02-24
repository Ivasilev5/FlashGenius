FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

COPY go.mod go.sum ./ 
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o flashcard-backend ./cmd/server

FROM alpine:3.19

WORKDIR /app

COPY --from=builder /app/flashcard-backend /app/flashcard-backend

ENV APP_PORT=8080

EXPOSE 8080

CMD ["/app/flashcard-backend"]

