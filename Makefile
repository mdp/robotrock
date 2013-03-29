all: clean install

install:
	npm install

clean: ;rm -rf node_modules

# to create env.json file
ENV='.env'

_pwd_prompt:
	@echo "Contact mdp@yahoo-inc.com for the password."

decrypt_config: _pwd_prompt
	openssl aes-256-cbc -d -in ${ENV}.aes -out ${ENV}
	chmod 600 ${ENV}

# for updating .env/development.json
encrypt_config:
	openssl aes-256-cbc -e -in ${ENV} -out ${ENV}.aes

.PHONY: install clean decrypt_config _pwd_prompt encrypt_config
