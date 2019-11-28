#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no directories are defined" && {

	context "ign directories" && {
		it "should report 'none defined'" && {

			out=$(ign directories) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign directories --list" && {
		it "should report ''" && {

			out=$(ign directories --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign directories ruby" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign directories ruby) 
 
			expect $out to_be "ruby - not found"
		}
		it "does not have script record file" && {
			expect "./input/directories/ruby.yaml" not to_exist
		}
	}
	
	context "ign directories ruby path=/usr/local/bin/ruby" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign directories ruby path=/usr/local/bin/ruby) 
 
			expect $out to_be "ruby - not found"
		}
	}	
}

describe "adding a directory" && {

	context "add directory" && {

		out=$(ign directories ruby --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: "
		}
		it "creates script record file" && {
			expect "./input/directories/ruby.yaml" to_exist
		}
	}
    
    context "add path" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby path=/usr/local/bin/ruby) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby"
		}     	 	
	}

    context "add user" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby user.name=bob) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    name: bob" 
		}     	 	
	}
	
	context "add group" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby group.name=builders) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    name: bob" \
								"  group:" \
								"    name: builders"
		}     	 	    	 	
	}
	context "add directory user id" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby user.id=1000) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    id: 1000"\
								"    name: bob" \
								"  group:" \
								"    name: builders"  
		}     	 	    	 	
	}	
	context "remove user name" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby user.name=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    id: 1000" \
								"  group:" \
								"    name: builders"  
		}  	 	
	}
	
    context "remove directory user.id" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby user.id=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  group:" \
								"    name: builders"
		}    	 	
	}
	
	context "remove directory user" && {
    
		it "shows updated record" && {
		
			out=$(ign directories ruby user=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.directories[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  group:" \
								"    name: builders" 
		}    	 	
	}
}

describe "deleting a directory" && {
	context "ign directories ruby --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign directories ruby --delete) ; should_succeed
		
			expect "$out" to_match "Moved ruby.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/directories/ruby.yaml" not to_exist
		}
	}
	context "ign directories --list" && {
		it "should report ''" && {
			out=$(ign directories --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}

 