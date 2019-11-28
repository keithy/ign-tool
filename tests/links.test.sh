#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no links are defined" && {

	context "ign links" && {
		it "should report 'none defined'" && {

			out=$(ign links) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign links --list" && {
		it "should report ''" && {

			out=$(ign links --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign links ruby" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign links ruby) 
 
			expect $out to_be "ruby - not found"
		}
		it "does not have script record file" && {
			expect "./input/links/ruby.yaml" not to_exist
		}
	}
	
	context "ign links ruby path=/usr/local/bin/ruby" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign links ruby path=/usr/local/bin/ruby) 
 
			expect $out to_be "ruby - not found"
		}
	}	
}

describe "adding a link" && {

	context "add link" && {

		out=$(ign links ruby --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: " \
								"  target: "
		}
		it "creates script record file" && {
			expect "./input/links/ruby.yaml" to_exist
		}
	}
    
    context "add path and target" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby path=/usr/local/bin/ruby target=/usr/local/lib/ruby-2.0.0/ruby) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby"
		}     	 	
	}

    context "add user" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby user.name=bob) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    name: bob" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby" 

		}     	 	
	}
	
	context "add group" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby group.name=builders) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    name: bob" \
								"  group:" \
								"    name: builders" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby" 
		}     	 	    	 	
	}
	context "add link user id" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby user.id=1000) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    id: 1000"\
								"    name: bob" \
								"  group:" \
								"    name: builders" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby"
		}     	 	    	 	
	}	
	context "remove user name" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby user.name=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  user:" \
								"    id: 1000" \
								"  group:" \
								"    name: builders" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby"
		}  	 	
	}
	
    context "remove link user.id" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby user.id=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  group:" \
								"    name: builders" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby"
		}    	 	
	}
	
	context "remove link user" && {
    
		it "shows updated record" && {
		
			out=$(ign links ruby user=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"storage.links[+]:" \
								"  path: /usr/local/bin/ruby" \
								"  group:" \
								"    name: builders" \
								"  target: /usr/local/lib/ruby-2.0.0/ruby"
		}    	 	
	}
}

describe "deleting a link" && {
	context "ign links ruby --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign links ruby --delete) ; should_succeed
		
			expect "$out" to_match "Moved ruby.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/links/ruby.yaml" not to_exist
		}
	}
	context "ign links --list" && {
		it "should report ''" && {
			out=$(ign links --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}

 