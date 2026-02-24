FROM alpine:latest

WORKDIR /app

# Install ca-certificates and tzdata
RUN apk --no-cache add ca-certificates tzdata

# Copy the pre-built binary (built in CI)
COPY city-r-app .

# Copy templates and static assets
COPY views/ ./views/
COPY static/ ./static/

# Set environment variables
ENV PORT=3000

# Expose port
EXPOSE 3000

# Run the application
CMD ["./city-r-app"]
