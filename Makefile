.PHONY : 



run_docker:
	unset LOG_LEVEL DATABASE_URL PORT DB DB_MAX_IDLE DB_MAX_OPEN DB_MAX_LIFE_TIME DB_MAX_IDLE_TIME ZAP_CONF GORM_CONF PPROF_ENABLE
	docker compose --env-file .env_local up       

clean_docker:
	docker rmi -f user-service
	docker rmi -f department-service
	docker rmi -f point-service

clean_point:
	docker container rm -f $$(docker ps -aq)
	docker rmi bmc-point_service

clean_user:
	docker container rm -f $$(docker ps -aq)
	docker rmi bmc-user_service


test: 
	go test -v ./...

test_race:
	go test ./... -race


protoc_point_v1:
	protoc \
	--go_out=. \
	--go_opt=paths=source_relative \
	--go-grpc_out=. \
	--go-grpc_opt=paths=source_relative \
	proto/v1/point/point.proto

bi:
	eval "$$(minikube docker-env)" && docker build -t user-service:latest -f service/user_service/Dockerfile . && docker build -t department-service:latest -f service/department_service/Dockerfile . && docker build -t point-service:latest -f service/point_service/Dockerfile .

deploy_to_k8:
	kubectl apply -f k8/zap-logger-config.yaml
	kubectl apply -f k8/gorm-logger-config.yaml
	kubectl apply -f k8/all-configmap.yaml
	kubectl apply -f k8/user-deployment.yaml
	kubectl apply -f k8/user-service.yaml
	kubectl apply -f k8/department-deployment.yaml
	kubectl apply -f k8/department-service.yaml
	kubectl apply -f k8/point-deployment.yaml
	kubectl apply -f k8/point-service.yaml
	kubectl apply -f k8/postgres-pvc.yaml
	kubectl apply -f k8/postgres-secret.yaml
	kubectl apply -f k8/postgres-configmap.yaml
	kubectl apply -f k8/postgres-deployment.yaml
	kubectl apply -f k8/postgres-service.yaml
	
deploy_secret:
	kubectl create secret generic all-service-secret --from-env-file=k8/.env_local

deploy_istio:
	kubectl label namespace default istio-injection=enabled
	kubectl apply -f k8/istio/gateway.yaml
	kubectl apply -f k8/istio/user-service-virtualservice.yaml
	kubectl apply -f k8/istio/department-service-virtualservice.yaml
	kubectl apply -f k8/istio/point-service-virtualservice.yaml

deploy_helm_install:
	kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/controller.yaml
	helm install common helm-charts/common
	helm install postgres helm-charts/postgres
	helm install department-service helm-charts/department-service
	helm install point-service helm-charts/point-service
	helm install user-service helm-charts/user-service

deploy_helm_upgrade:
	helm upgrade common helm-charts/common
	helm upgrade postgres helm-charts/postgres
	helm upgrade department-service helm-charts/department-service
	helm upgrade point-service helm-charts/point-service
	helm upgrade user-service helm-charts/user-service


md:
	minikube delete

ms:
	minikube start
	~/istio-1.25.2/bin/istioctl install --set profile=default -y
	kubectl label namespace default istio-injection=enabled

ag:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

agi:
	kubectl apply -f agrocd/common-app.yaml
	kubectl apply -f agrocd/postgres-app.yaml
	kubectl apply -f agrocd/point-service-app.yaml
	kubectl apply -f agrocd/user-service-app.yaml
	kubectl apply -f agrocd/department-service-app.yaml