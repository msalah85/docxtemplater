#!/bin/bash

set -euo pipefail
pid=""

cleanup() {
	if [ "$pid" != "" ]
	then
		while true
		do
			kill "$pid" 1>/dev/null 2>&1 || break
			sleep 1
		done
	fi
}
trap "cleanup" EXIT INT
BROWSER="${BROWSER:-CHROME|FIREFOX|}"
PATH="$PATH:./node_modules/.bin/"
if grep '|' <<<"$BROWSER" >/dev/null
then
	while read -d '|' browser
	do
		echo "$browser"
		BROWSER="$browser" ./webdriver.bash
	done <<<"$BROWSER"
	exit 0
fi

if [ "$BROWSER" != "SAUCELABS" ]
then
	if netstat -tnlp 2>/dev/null | grep --color -E 4444 >/dev/null
	then
		echo "Using existing selenium"
	else
		selenium-standalone install --silent
		selenium-standalone start -- -log /tmp/protractor.log &
		pid="$!"
	fi
	node webdriver.js
	exit "$?"
fi

result=0

browserName="MicrosoftEdge" platform="Windows 10" version="16.16299" node webdriver.js || result=1
browserName="safari" platform="macOs 10.12" version="11.0" filter="Speed test" node webdriver.js || result=1
browserName="chrome" platform="Windows 10" version="58" node webdriver.js || result=1
browserName="firefox" platform="Windows 10" version="55" node webdriver.js || result=1
browserName="internet explorer" platform="Windows 10" version="11" node webdriver.js || result=1
browserName="iphone" platform="Mac 10.11" version="10.2" node webdriver.js || result=1
exit "$result"
