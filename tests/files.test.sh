#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "adding a file with inline contents" && {

	context "when no files exit"  && {
		it "should report new record with inline content" && {

			out=$(ign files ipcress path=/the/file contents.inline=this\\nis\\nit --add ; echo "<END") && should_succeed	 

			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    inline: |" \
								"      this" \
								"      is" \
								"      it" \
								"<END" #verify trailing empty line 
		}
	}
	
	context "mode user group"  && {
		it "should report new record with everything" && {

			out=$(ign files ipcress mode=777 user.id=1000 user.name=me group.id=1001 group.name=us ; echo "<END") && should_succeed	 

			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    inline: |" \
								"      this" \
								"      is" \
								"      it" \
								"  mode: 777" \
								"  user:" \
								"    id: 1000" \
								"    name: me" \
								"  group:" \
								"    id: 1001" \
								"    name: us" \
								"<END" #verify trailing empty line 
		}
	}
	context "deleting a file" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign files ipcress --delete) ; should_succeed
		
			expect "$out" to_match "Moved ipcress.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/files/ipcress.yaml" not to_exist
		}
	}
	context "ign files --list" && {
		it "should report ''" && {
			out=$(ign files --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}

describe "adding a file with inline contents from file" && {

	context "when no files exit"  && {
		it "should report new record with inline content" && {

			out=$(ign files ipcress path=/the/file contents.inline_file=test.service --add ; echo "<END") && should_succeed	 

 			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    inline: |" \
								"      to be" \
								"      or not" \
								"      to be" \
								"<END" #verify trailing empty line 
		}
	}
	context "reload file"  && {
   
	   it "verify no change" && {
	
			out=$(ign files ipcress; echo "<END") && should_succeed	 
	
			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    inline: |" \
								"      to be" \
								"      or not" \
								"      to be" \
								"<END" #verify trailing empty line 
	   }
	}
	ign files ipcress --delete
}

describe "adding a file with remote source" && {

	context "no files exit"  && {
		it "should report new record with source content" && {

			out=$(ign files ipcress path=/the/file contents.source=https://getfedora.org/static/images/logo-inline-coreos.png --add ; echo "<END") && should_succeed	 

			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    source: https://getfedora.org/static/images/logo-inline-coreos.png" \
								"<END" #verify trailing empty line 
		}
	}
	context "reload file"  && {
   
	   it "verify no change" && {

			out=$(ign files ipcress; echo "<END") && should_succeed	 

 						expect "$out" to_be "ipcress.yaml" \
											"storage.files[+]:" \
  											"  path: /the/file" \
  											"  contents:" \
											"    source: https://getfedora.org/static/images/logo-inline-coreos.png" \
											"<END" #verify trailing empty line 
		}
	}
	context "generate hash automativally"  && {
   
	   it "verify hash" && {

			out=$(ign files ipcress --hash; echo "<END") && should_succeed	 

			expect "$out" to_be "ipcress.yaml" \
								"storage.files[+]:" \
								"  path: /the/file" \
								"  contents:" \
								"    source: https://getfedora.org/static/images/logo-inline-coreos.png" \
								"    verification:" \
								"      hash: sha512-50856f63fb9646821f8b2bf4d00910cdf7dc07d68c643e7025c947b4d98fba41e4983b202be973b4503ce9a85ed6fd579af27e34cc875c3a895f612378f9b70c" \
								"<END" #verify trailing empty line 
		}
	}
	ign files ipcress --delete
}

 