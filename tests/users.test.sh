#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no users are defined" && {

	context "ign users" && {
		it "should report 'none defined'" && {

			out=$(ign users) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign users --list" && {
		it "should report ''" && {

			out=$(ign users --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign users bob" && {
		
		it "should report 'bob - not found'" && {
			out=$(ign users bob) 
 
			expect $out to_be "bob - not found"
		}
		it "does not have script record file" && {
			expect "./input/users/bob.yaml" not to_exist
		}
	}
	
	context "ign users bob uid=10" && {
		
		it "should report 'bob - not found'" && {
			out=$(ign users bob uid=10) 
 
			expect $out to_be "bob - not found"
		}
	}	
}

describe "adding a user" && {

	context "add user" && {

		out=$(ign users bob --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob"
		}
		it "creates script record file" && {
			expect "./input/users/bob.yaml" to_exist
		}
	}
    
    context "add uid" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob uid=111) ; should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob" \
								"  uid: 111"
		}     	 	
	}

    context "add system" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob system=true) ; should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob" \
								"  uid: 111" \
								"  system: true"
		}     	 	
	}
	
	context "add password" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob 'password_hash=$5$lr7WA/EN75k$lpTSE7E0uJzaA4Ewxp3sRP0RBPsfnrWPB1kKAfmahY0') 
			should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob" \
								'  password_hash: $5$lr7WA/EN75k$lpTSE7E0uJzaA4Ewxp3sRP0RBPsfnrWPB1kKAfmahY0' \
								"  uid: 111" \
								"  system: true"
		}     	 	
	}
	context "remove password" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob password_hash=) 
			should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob" \
								"  uid: 111" \
								"  system: true"
		}     	 	
	}
	
    context "remove uid" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob uid=) ; should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob" \
								"  system: true"
		}     	 	
	}
	
	context "remove system" && {
    
		it "shows updated record" && {
		
			out=$(ign users bob system=) ; should_succeed
		
			expect "$out" to_be "bob.yaml" \
								"passwd.users[+]:" \
								"  name: bob"
		}     	 	
	}
	
	context "ign users --list" && {
    
		it "shows list of names" && {
		
			out=$(ign users --list) ; should_succeed
		
			expect "$out" to_be "bob"
		}     	 	
	}
}

describe "deleting a user" && {
	context "ign users bob --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign users bob --delete) ; should_succeed
		
			expect "$out" to_match "Moved bob.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/users/bob.yaml" not to_exist
		}
	}
	context "ign users --list" && {
		it "should report ''" && {

			out=$(ign users --list) ; should_succeed	 

 			expect "$out" to_be ""
		}
	}
}

describe "adding a user in one line" && {

	context "add user" && {

		it "shows user record" && {
			out=$(ign users ben --add uid=1001 primary_group=flowerpot_men) ; should_succeed
		
			expect "$out" to_be "ben.yaml" \
									"passwd.users[+]:" \
									"  name: ben" \
									"  uid: 1001" \
									"  primary_group: flowerpot_men" 
			ign users ben --delete
		}	 	 
	}
}

describe "list-subitem groups" && {

	context "add groups" && {

		it "shows user record with groups as a sub-list " && {
			out=$(ign users ben groups+=celebrities groups+=toys --add) ; should_succeed
		
			expect "$out" to_be "ben.yaml" \
									"passwd.users[+]:" \
									"  name: ben" \
									"  groups:" \
									"  - toys" \
									"  - celebrities"
		}
	}
	context "remove group" && {

		it "shows user record with groups as a sub-list " && {
			out=$(ign users ben groups-=celebrities) ; should_succeed
		
			expect "$out" to_be "ben.yaml" \
									"passwd.users[+]:" \
									"  name: ben" \
									"  groups:" \
									"  - toys"
		}
			
	}
	context "remove last group" && {

		it "shows user record with groups as a sub-list " && {
			out=$(ign users ben groups-=toys) ; should_succeed
		
			expect "$out" to_be "ben.yaml" \
									"passwd.users[+]:" \
									"  name: ben"
		}
	}
	ign users ben --delete
}

context "add password using user interaction" && {
    
		it "shows updated record" && {

		${DIR}/password_entry.exp		
# 		/usr/local/bin/expect <<- EXPECTSCRIPT
# 			spawn ign users ben --password --add --theme=0
# 			expect -exact "Password: "
# 			send -- "password\r"
# 			expect {
# 			  "ben.yaml\r\npasswd.users\\\[+\]\:\r\n  name: ben\r\n  password_hash: \$6\$rounds=656000\$*\r"
# 				 { send_user "Test completed.\n"; exit 0 }}
# 			exit 1
# 		EXPECTSCRIPT

		should_succeed 
	}
}
