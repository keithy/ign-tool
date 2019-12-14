#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

NL=$'\n'

which fcct || echo "Missing dependency for generating ignition - fcct"
which yq   || echo "Missing dependency for composing yaml - yq" 

# lets go!

describe "Run generate on empty workspace" && {

	context "ign generate - vanilla" && {

		out=$(ign generate --json) && should_succeed	 

		it "should return ignition json" && {
 			expect "$out" to_match "\{.*\"ignition\".*\"version\": \"[0-9]+\.[0-9]+\.[0-9]+\".*"
		}
	}
	
	context "ign generate --confirm" && {

		it "not yet" && {
			expect "./ignition.json" not to_exist
		}
		
		out=$(ign generate --confirm) ; should_succeed

		it "creates output json file" && {
			expect "./ignition.json" to_exist
		}
		
		expect "$(cat ./ignition.json)" to_match "\{.*\"ignition\".*\"version\": \"[0-9]+\.[0-9]+\.[0-9]+\".*"
		
	}
	
	context "ign generate -V - verbose output" && {
 
		out=$(ign generate -V) ; should_succeed

		it "demos variable substitution in input" && {
			expect "$out" to_match ".*header:${NL}.*variant: \\$\{VARIANT\}${NL}.*"
		}
		
		it "demos variable list" && {
			expect "$out" to_match "vars required:${NL}${VARIANT}${NL}.*"
		}
		it "variable substitution works" && {
			expect "$out" to_match "${NL}yaml:${NL}.*${NL}variant: fcos${NL}.*"
		}
				
		it "json output" && {		
			expect "$out" to_match "\{.*\"ignition\".*\"version\": \"[0-9]+\.[0-9]+\.[0-9]+\".*"
		}
	}
}
