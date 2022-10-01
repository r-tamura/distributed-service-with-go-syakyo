.PHONY: compile
compile:
	protoc api/v1/*.proto \
			--go_out=. \
			--go_opt=paths=source_relative \
			--proto_path=.

# https://github.com/golang/go/issues/27089#issuecomment-933016414
# -raceオプションをつけるとgccが要求されビルドエラーになる。--vet=offすると動く
.PHONY: test
test:
	go test -race --vet=off ./...