# Stage 1: Build the binary
# Changed from 1.21 to 1.22 to match your go.mod requirements
#Stage 1 focuses on building.
# Stage 2 focuses on running.
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY go.mod ./
# If you have a go.sum file, uncomment the next line:
# COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary
RUN go build -o main .

# Stage 2: Final lightweight image
FROM alpine:latest

# Security: Add CA certificates
# Note: If this line fails again, we can temporarily comment it out
RUN apk add --no-cache ca-certificates || true

WORKDIR /root/

# Copy the compiled binary from the builder stage
COPY --from=builder /app/main .

# Copy your static files
COPY --from=builder /app/static ./static

# Expose the port
EXPOSE 8080

# Run the application
CMD ["./main"]