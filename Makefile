CONFIG_PATH=${HOME}/.proglog/

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

.PHONY: gencert
gencert:
	cfssl gencert \
			-initca test/ca-csr.json | cfssljson -bare ca

	cfssl gencert \
			-ca=ca.pem \
			-ca-key=ca-key.pem \
			-config=test/ca-config.json \
			-profile=server \
			test/server-csr.json | cfssljson -bare server

	cfssl gencert \
			-ca=ca.pem \
			-ca-key=ca-key.pem \
			-config=test/ca-config.json \
			-profile=client \
			-cn="root" \
			test/client-csr.json | cfssljson -bare root-client

	cfssl gencert \
			-ca=ca.pem \
			-ca-key=ca-key.pem \
			-config=test/ca-config.json \
			-profile=client \
			-cn="nobody" \
			test/client-csr.json | cfssljson -bare nobody-client

	mv *.pem *.csr ${CONFIG_PATH}

# 別のCAから発行した証明書でテストが失敗することを確認する
.PHONY: genfraudcert
genfraudcert:
	cfssl gencert \
			-initca test/ca2-csr.json | cfssljson -bare ca2
	cfssl gencert \
			-ca=ca2.pem \
			-ca-key=ca2-key.pem \
			-config=test/ca-config.json \
			-profile=client \
			test/client-csr.json | cfssljson -bare client2

	mv *.pem *.csr ${CONFIG_PATH}


.PHONY: compile
compile:
	protoc api/v1/*.proto \
			--go_out=. \
			--go-grpc_out=. \
			--go_opt=paths=source_relative \
			--go-grpc_opt=paths=source_relative \
			--proto_path=.

${CONFIG_PATH}/model.conf:
	cp test/model.conf ${CONFIG_PATH}/model.conf

${CONFIG_PATH}/policy.conf:
	cp test/policy.csv ${CONFIG_PATH}/policy.csv

# https://github.com/golang/go/issues/27089#issuecomment-933016414
# -raceオプションをつけるとgccが要求されビルドエラーになる。--vet=offすると動く
.PHONY: test
test: ${CONFIG_PATH}/model.conf ${CONFIG_PATH}/policy.conf
	go test -race --vet=off ./...
