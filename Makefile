.PHONY : 

include .env_local
export


run_docker:
	unset LOG_LEVEL DATABASE_URL PORT DB DB_MAX_IDLE DB_MAX_OPEN DB_MAX_LIFE_TIME DB_MAX_IDLE_TIME ZAP_CONF GORM_CONF PPROF_ENABLE
	docker compose --env-file .env_local up       

clean_docker:
	docker rmi -f bk-user_service
	docker rmi -f bk-department_service
	docker rmi -f bk-point_service

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

deploy_to_k8:
	docker build -t user-service:latest -f service/user_service/Dockerfile .
	docker build -t department-service:latest -f service/department_service/Dockerfile .
	docker build -t point-service:latest -f service/point_service/Dockerfile .
	kubectl create secret generic all-service-secret --from-env-file=k8/.env_local
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