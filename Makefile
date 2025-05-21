PROTO_OUT := protogen/go

.PHONY: dir
dir:
ifeq ($(OS),Windows_NT)
	@powershell -Command "if (!(Test-Path '$(PROTO_OUT)')) { New-Item -ItemType Directory -Path '$(PROTO_OUT)' }"
else
	@mkdir -p $(PROTO_OUT)
endif

.PHONY: pipeline-init
pipeline-init:
	sudo apt-get install -y protobuf-compiler curl unzip
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	# Install protoc-gen-validate
	curl -L -o /tmp/protoc-gen-validate.tar.gz https://github.com/bufbuild/protoc-gen-validate/releases/download/v1.2.1/protoc-gen-validate_1.2.1_linux_amd64.tar.gz && \
		sudo tar -xzf /tmp/protoc-gen-validate.tar.gz -C /usr/local/bin && \
		sudo chmod +x /usr/local/bin/protoc-gen-validate && \
		sudo rm /tmp/protoc-gen-validate.tar.gz

.PHONY: pipeline-build
pipeline-build: pipeline-init dir protoc-go

.PHONY: protoc-go
protoc-go:
	protoc \
		--proto_path=./proto \
		--go_out=paths=source_relative:$(PROTO_OUT) \
		--go-grpc_out=paths=source_relative:$(PROTO_OUT) \
		--grpc-gateway_out=paths=source_relative:$(PROTO_OUT) \
		--validate_out=lang=go:$(PROTO_OUT) \
		./proto/*.proto
	@if [ -d "$(PROTO_OUT)/github.com" ]; then \
		mv $(PROTO_OUT)/github.com/goffyshop/proto/* $(PROTO_OUT)/ && rm -rf $(PROTO_OUT)/github.com; \
	fi
