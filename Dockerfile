# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application securely
RUN CGO_ENABLED=0 GOOS=linux go build -o city-r-app .

# Final stage - using a very lightweight alpine image
FROM alpine:latest

# Install tzdata just in case the app needs timezone information
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/city-r-app .

# Copy static assets and HTML templates
COPY views/ ./views/
COPY static/ ./static/

# Expose port 3000
EXPOSE 3000

# Run the app
CMD ["./city-r-app"]
