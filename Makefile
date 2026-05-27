BINARY := bin/secrets
DIR    := retrieve-secret-layer

.PHONY: build clean

build:
	cd $(DIR) && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o $(BINARY) ./...

clean:
	rm -f $(DIR)/$(BINARY)
