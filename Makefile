#-----------------------------------------------------------------------------
#   Copyright (c) 2008 by David P. D. Moss. All rights reserved.
#
#   Released under the BSD license. See the LICENSE file for details.
#-----------------------------------------------------------------------------
#
# netaddr library build script
#
SHELL = /bin/bash

.PHONY = default clean dist doc download test

default:
	@echo 'Please select a build target.'

clean:
	@echo 'cleaning up temporary files'
	rm -rf dist/
	rm -rf build/
	rm -rf docs/build/
	rm -rf netaddr.egg-info/
	find . -name '*.pyc' -exec rm -f {} ';'
	find . -name '*.pyo' -exec rm -f {} ';'

dist: clean
	pip install --upgrade build
	@echo 'building netaddr release'
	python -m build

doc:
	@echo 'building documentation'
	pip install sphinx
	pip install -r docs/requirements.txt
	pip install -e .
	cd docs/ && $(MAKE) -f Makefile clean html
	cd docs/build/html && zip -r ../netaddr.zip *

download:
	@echo 'downloading latest IEEE data'
	cd netaddr/eui/ && wget http://standards-oui.ieee.org/oui/oui.txt -O oui.txt
	cd netaddr/eui/ && wget http://standards-oui.ieee.org/iab/iab.txt -O iab.txt
	@echo 'rebuilding IEEE data file indices'
	python netaddr/eui/ieee.py
	@echo 'downloading latest IANA data'
	cd netaddr/ip/ && wget https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.xml -O ipv4-address-space.xml
	cd netaddr/ip/ && wget https://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xml -O ipv6-address-space.xml
	cd netaddr/ip/ && wget https://www.iana.org/assignments/multicast-addresses/multicast-addresses.xml -O multicast-addresses.xml
	cd netaddr/ip/ && wget https://www.iana.org/assignments/ipv6-unicast-address-assignments/ipv6-unicast-address-assignments.xml -O ipv6-unicast-address-assignments.xml

register:
	@echo 'releasing netaddr'
	python setup_egg.py register

push_tags:
	@echo 'syncing tags'
	git push --tags

ci: lint test-ci

lint:
	ruff format --check

fix:
	ruff format

test:
	@echo 'running test suite'
	pytest

.PHONY: test-ci
test-ci:
	pytest --cov-report term --cov-report html --cov-report xml --cov-report term-missing --cov=netaddr --cov-branch
