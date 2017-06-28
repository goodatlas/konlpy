# Deployment instructions
# 0. Fill in `pypirc.sample`, and `cp pypirc.sample ~/.pypirc`
# 1. Check changelogs.rst
# 2. Check translations at docs/locale/ko/LC_MESSAGES/*.po
# 3. Check version at konlpy/__init__.py
# 4. $ make testpypi
# 5. $ make pypi # Beware not to change the version number at this stage!!!
# 6. Document update at RTD (latest)
# 7. Push tag
# 8. Document update at RTD (current version)
#
# TODO: use flake8 and/or pylint


# Exit with error if GEMFURY_PYPI is not set when publishing python
ifeq ($(MAKECMDGOALS), $(filter $(MAKECMDGOALS), publish, install-dev))
ifndef GEMFURY_PYPI
$(error GEMFURY_PYPI is not set)
endif
endif

# When publishing tags
ifeq ($(MAKECMDGOALS), $(filter $(MAKECMDGOALS), publish publish-version-tag))
# Ask for github credentials
ifndef GITHUB_CREDENTIALS
GITHUB_CREDENTIALS := $(shell read -p "Enter github credentials(USERNAME:PASSWORD): ";echo $$REPLY)
endif

# Do a release check
ifdef CI
RELEASE_CHECK_FLAGS := "--skip-build-check"
RELEASE_CHECK_ALLOW_ERR := 0 3
else
RELEASE_CHECK_ALLOW_ERR := 0
endif

RELEASE_CHECK := $(shell ./script/check-release \
	$(GITHUB_CREDENTIALS) \
	$(RELEASE_CHECK_FLAGS) \
	1>&2 \
	; echo "$$?")

ifneq ($(RELEASE_CHECK), $(filter $(RELEASE_CHECK), $(RELEASE_CHECK_ALLOW_ERR)))
$(error release-check exit code: $(RELEASE_CHECK))
endif
endif

# Check that VERSION si set when checking or bumping version
ifeq ($(MAKECMDGOALS), $(filter $(MAKECMDGOALS), check-version bump-version))
ifndef VERSION
$(error VERSION is not set. ex "make $(filter $(MAKECMDGOALS),check-version bump-version) VERSION=1.2.3")
endif
endif



check:
	check-manifest
	pyroma dist/konlpy-*tar.gz
	pep8 --ignore==E501 konlpy/*.py
	pep8 --ignore==E501 konlpy/*/*.py

testpypi:
	sudo python setup.py register -r pypitest
	sudo python setup.py sdist --formats=gztar,zip upload -r pypitest
	sudo python setup.py bdist_wheel upload -r pypitest
	# Execute below manually
	# 	cd /tmp
	# 	virtualenv venv
	# 	source venv/bin/activate
	# 	pip install -i https://testpypi.python.org/pypi konlpy
	# 	deactivate
	# 	virtualenv-3.4 venv3
	# 	source venv3/bin/activate
	# 	pip3 install -i https://testpypi.python.org/pypi konlpy
	# 	deactivate

pypi:
	sudo python setup.py register -r pypi
	sudo python setup.py sdist --formats=gztar,zip upload -r pypi
	sudo python setup.py bdist_wheel upload -r pypi

java:
	ant compile

jcc:
	python -m jcc \
	    --jar konlpy/java/jhannanum-0.8.4.jar \
	    --classpath konlpy/java/bin/kr/lucypark/jhannanum \
	    --python pyhannanum \
	    --version 0.1.0 \
	    --build --install

testall:
	python -m pytest --cov=konlpy test/
	python3 -m pytest --cov=konlpy test/

init_i18n:
	pip install mock sphinx sphinx-intl
	git submodule init
	git submodule update

extract_i18n:
	cd docs\
	    && make gettext\
	    && sphinx-intl update -p _build/locale -l ko

update_i18n:
	cd docs\
	    && sphinx-intl build\
	    && make -e SPHINXOPTS="-D language='ko'" html
