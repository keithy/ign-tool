#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -RP ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no groups are defined" && {

	context "ign groups" && {
		it "should report 'none defined'" && {

			out=$(ign groups) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign groups --list" && {
		it "should report ''" && {

			out=$(ign groups --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign groups hug" && {
		
		it "should report 'hug - not found'" && {
			out=$(ign groups hug) 
 
			expect $out to_be "hug - not found"
		}
		it "does not have script record file" && {
			expect "./input/passwd/groups/hug.yaml" not to_exist
		}
	}
	
	context "ign groups hug --gid 10" && {
		
		it "should report 'hug - not found'" && {
			out=$(ign groups hug) 
 
			expect $out to_be "hug - not found"
		}
	}	
}

describe "adding a group" && {

	context "add group" && {

		out=$(ign groups hug --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug"
		}
		it "creates script record file" && {
			expect "./input/passwd/groups/hug.yaml" to_exist
		}
	}
    
    context "add gid" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --gid 111) ; should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug" \
								"  gid: 111"
		}     	 	
	}

    context "add system" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --system=true) ; should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug" \
								"  gid: 111" \
								"  system: true"
		}     	 	
	}
	
	context "add password" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --password_hash '$5$lr7WA/EN75k$lpTSE7E0uJzaA4Ewxp3sRP0RBPsfnrWPB1kKAfmahY0') 
			should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug" \
								"  gid: 111" \
								"  system: true" \
								'  password_hash: $5$lr7WA/EN75k$lpTSE7E0uJzaA4Ewxp3sRP0RBPsfnrWPB1kKAfmahY0'
		}     	 	
	}
	
	context "remove password" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --password_hash false) 
			should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug" \
								"  gid: 111" \
								"  system: true"
		}     	 	
	}
	
    context "remove gid" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --gid 0) ; should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug" \
								"  system: true"
		}     	 	
	}
	
	context "remove system" && {
    
		it "shows updated record" && {
		
			out=$(ign groups hug --system=false) ; should_succeed
		
			expect "$out" to_be "hug.yaml" \
								"passwd.groups[+]:" \
								"  name: hug"
		}     	 	
	}
	
	context "ign groups --list" && {
    
		it "shows list of names" && {
		
			out=$(ign groups --list) ; should_succeed
		
			expect "$out" to_be "hug"
		}     	 	
	}
}

describe "deleting a group" && {
	context "ign groups hug --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign groups hug --delete) ; should_succeed
		
			expect "$out" to_be "Moved hug.yaml to /Users/keith/.Trash"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/groups/hug.yaml" not to_exist
		}
	}
	context "ign groups --list" && {
		it "should report ''" && {
			out=$(ign groups --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}
