publish:
	rm -rf ./publish/create_oai/
	mkdir -p ./publish/create_oai
	cp -r ./create_oai ./publish/
	pip install -t ./publish/create_oai -r ./publish/create_oai/requirements.txt
	cd ./publish/create_oai && zip -r ../create_oai.zip .

clean:
	@echo "--> Cleaning pyc files"
	find . -name "*.pyc" -delete
	rm -rf ./publish
	@echo ""
