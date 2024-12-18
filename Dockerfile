FROM golang:1.23.3 AS dev
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

RUN go install golang.org/x/lint/golint@latest

COPY . .

RUN make linux-build
