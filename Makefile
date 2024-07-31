
.ONESHELL:
.SILENT:

WEBSERVICE_NAME = burla-docs-website

ARTIFACT_REPO_NAME := $(WEBSERVICE_NAME)
ARTIFACT_PKG_NAME := $(WEBSERVICE_NAME)
TEST_IMAGE_BASE_NAME := us-docker.pkg.dev/burla-test/$(ARTIFACT_REPO_NAME)/$(ARTIFACT_PKG_NAME)
PROD_IMAGE_BASE_NAME := us-docker.pkg.dev/burla-prod/$(ARTIFACT_REPO_NAME)/$(ARTIFACT_PKG_NAME)

dev:
	npx docusaurus start

test:
	poetry run pytest -s --disable-warnings

service:
	poetry run uvicorn $(WEBSERVICE_NAME):application --host 0.0.0.0 --port 5002 --reload

deploy-test:
	set -e; \
	TEST_IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=$(ARTIFACT_PKG_NAME) \
			--location=us \
			--repository=$(ARTIFACT_REPO_NAME) \
			--project=burla-test \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	TEST_IMAGE_NAME=$$( echo $(TEST_IMAGE_BASE_NAME):$${TEST_IMAGE_TAG} ); \
	gcloud run deploy $(WEBSERVICE_NAME) \
	--image=$${TEST_IMAGE_NAME} \
	--project burla-test \
	--region=us-central1 \
	--min-instances 1 \
	--max-instances 20 \
	--memory 4Gi \
	--cpu 1 \
	--concurrency 10

move-test-image-to-prod:
	set -e; \
	TEST_IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=$(ARTIFACT_PKG_NAME) \
			--location=us \
			--repository=$(ARTIFACT_REPO_NAME) \
			--project=burla-test \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	TEST_IMAGE_NAME=$$( echo $(TEST_IMAGE_BASE_NAME):$${TEST_IMAGE_TAG} ); \
	PROD_IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=$(ARTIFACT_PKG_NAME) \
			--location=us \
			--repository=$(ARTIFACT_REPO_NAME) \
			--project=burla-prod \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	NEW_PROD_IMAGE_TAG=$$(($${PROD_IMAGE_TAG} + 1)); \
	PROD_IMAGE_NAME=$$( echo $(PROD_IMAGE_BASE_NAME):$${NEW_PROD_IMAGE_TAG} ); \
	docker pull $${TEST_IMAGE_NAME}; \
	docker tag $${TEST_IMAGE_NAME} $${PROD_IMAGE_NAME}; \
	docker push $${PROD_IMAGE_NAME}

deploy-prod:
	set -e; \
	echo ; \
	echo HAVE YOU MOVED THE LATEST TEST-IMAGE TO PROD?; \
	while true; do \
		read -p "Do you want to continue? (yes/no): " yn; \
		case $$yn in \
			[Yy]* ) echo "Continuing..."; break;; \
			[Nn]* ) echo "Exiting..."; exit;; \
			* ) echo "Please answer yes or no.";; \
		esac; \
	done; \
	PROD_IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=$(ARTIFACT_PKG_NAME) \
			--location=us \
			--repository=$(ARTIFACT_REPO_NAME) \
			--project burla-prod \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	PROD_IMAGE_NAME=$$( echo $(PROD_IMAGE_BASE_NAME):$${PROD_IMAGE_TAG} ); \
	gcloud run deploy $(WEBSERVICE_NAME) \
	--image=$${PROD_IMAGE_NAME} \
	--project burla-prod \
	--region=us-central1 \
	--min-instances 1 \
	--max-instances 20 \
	--memory 4Gi \
	--cpu 1 \
	--concurrency 10 \
	--allow-unauthenticated

image:
	set -e; \
	TEST_IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=$(ARTIFACT_PKG_NAME) \
			--location=us \
			--repository=$(ARTIFACT_REPO_NAME) \
			--project burla-test \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	NEW_TEST_IMAGE_TAG=$$(($${TEST_IMAGE_TAG} + 1)); \
	TEST_IMAGE_NAME=$$( echo $(TEST_IMAGE_BASE_NAME):$${NEW_TEST_IMAGE_TAG} ); \
	gcloud builds submit --tag $${TEST_IMAGE_NAME} --machine-type "E2_HIGHCPU_32"; \
	echo "Successfully built Docker Image:"; \
	echo "$${TEST_IMAGE_NAME}"; \
	echo "";
