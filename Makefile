.ONESHELL:
.SILENT:

dev:
	npx docusaurus start

deploy-test:
	set -e; \
	IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=burla-docs \
			--location=us \
			--repository=burla-docs \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	IMAGE_NAME=$$( echo \
		us-docker.pkg.dev/burla-test/burla-docs/burla-docs:$${IMAGE_TAG} \
	); \
	gcloud run deploy burla-docs \
	--image=$${IMAGE_NAME} \
	--project burla-test \
	--region=us-central1 \
	--min-instances 1 \
	--max-instances 20 \
	--memory 4Gi \
	--cpu 1 \
	--concurrency 10

deploy-prod:
	set -e; \
	IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=burla-docs \
			--location=us \
			--repository=burla-docs \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	IMAGE_NAME=$$( echo \
		us-docker.pkg.dev/burla-test/burla-docs/burla-docs:$${IMAGE_TAG} \
	); \
	gcloud run deploy burla-docs \
	--image=$${IMAGE_NAME} \
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
	IMAGE_TAG=$$( \
		gcloud artifacts tags list \
			--package=burla-docs \
			--location=us \
			--repository=burla-docs \
			2>&1 | grep -Eo '^[0-9]+' | sort -n | tail -n 1 \
	); \
	NEW_IMAGE_TAG=$$(($${IMAGE_TAG} + 1)); \
	IMAGE_NAME=$$( echo \
		us-docker.pkg.dev/burla-test/burla-docs/burla-docs:$${NEW_IMAGE_TAG} \
	); \
	gcloud builds submit --tag $${IMAGE_NAME} --machine-type "E2_HIGHCPU_32"; \
	echo "Successfully built Docker Image:"; \
	echo "$${IMAGE_NAME}"; \
	echo "";
