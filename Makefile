.PHONY: collectstatic run test ci install install-dev migrations staticfiles lint format

help:
	@echo "Available commands"
	@echo "ci - lints, migrations, tests, coverage"
	@echo "install - installs production requirements"
	@echo "isort - sorts all imports of the project"
	@echo "runserver - runs the development server"
	@echo "setup-test-data - erases the db and loads mock data"
	@echo "shellplus - runs the development shell"
	@echo "lint - check style with black, flake8, sort python with isort, and indent html"
	@echo "format - enforce a consistent code style across the codebase and sort python files with isort"

collectstatic:
	python tango/manage.py collectstatic --noinput

clean:
	rm -rf __pycache__ .pytest_cache

check:
	python tango/manage.py check

check-deploy:
	python tango/manage.py check --deploy

makemessages:
	django-admin makemessages --all

compilemessages:
	django-admin compilemessages

install:
	poetry install

update:
	poetry update
	
setup_test_data:
	python tango/manage.py setup_test_data
	
shellplus:
	python tango/manage.py shell_plus --print-sql

shell:
	python tango/manage.py shell

showmigrations:
	python tango/manage.py showmigrations

makemigrations:
	python tango/manage.py makemigrations

migrate:
	python tango/manage.py migrate

migrations-check:
	python tango/manage.py makemigrations --check --dry-run

runserver:
	python tango/manage.py runserver

build: install makemigrations migrate runserver

format:
	poetry run isort . --profile django
	poetry run black .
	git ls-files '*.html' | xargs djlint --reformat

lint:
	poetry run isort --check-only --diff --profile django .
	poetry run black --check --diff .
	poetry run ruff .
	git ls-files '*.html' | xargs djlint --lint
	git ls-files '*.html' | xargs djlint --check

test: check migrations-check
	coverage run --source='.' tango/manage.py test
	coverage html

security:
	poetry run bandit -r .
	poetry run safety check

ci: lint security test

superuser:
	python tango/manage.py createsuperuser

status:
	@echo "Nginx"
	@sudo systemctl status nginx

	@echo "Gunicorn Socket"
	@sudo systemctl status wagtail.socket

	@echo "Gunicorn Service"
	@sudo systemctl status wagtail.service


reload:
	@echo "reloading daemon..."
	@sudo systemctl daemon-reload

	@echo "🔌 restarting gunicorn socket..."
	@sudo systemctl restart wagtail.socket

	@echo "🦄 restarting gunicorn service..."
	@sudo systemctl restart wagtail.service
	
	@echo "⚙️ reloading nginx..."
	@sudo nginx -s reload
	
	@echo "All done! 💅💫💖"

logs:
	@sudo journalctl -fu wagtail.service
	

	
