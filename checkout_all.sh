#!/bin/bash

REPOS=("ansible-celery" "ansible-django" "ansible-git" "ansible-gunicorn" "ansible-nginx"
"ansible-nltk" "ansible-personal_dev" "ansible-pip" "ansible-supervisord" "devbox" "dotfiles"
"freelancefinder" "http_trace" "kbwc_api_client" "oclc-auth-python" "pelican" "pelican_blog"
"python-amazon-simple-product-api" "resume" "scorpionresponse.github.com" "statistics-etl" "tablib"
"vagrant-bootstrap")
DEST="$HOME/development"

for repo in "${REPOS[@]}"
do
	echo "Checking out ${repo}"
	git clone "git@github.com:ScorpionResponse/${repo}.git" "${DEST}"/"${repo}"
done

echo "Done"
