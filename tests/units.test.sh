#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no units are defined" && {

	context "ign units" && {
		it "should report 'none defined'" && {

			out=$(ign units) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign units --list" && {
		it "should report ''" && {

			out=$(ign units --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign units ruby" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign units ruby) 
 
			expect $out to_be "ruby - not found"
		}
		it "does not have script record file" && {
			expect "./input/units/ruby.yaml" not to_exist
		}
	}
	
	context "ign units ruby enabled=true" && {
		
		it "should report 'ruby - not found'" && {
			out=$(ign units ruby) 
 
			expect $out to_be "ruby - not found"
		}
	}	
}

describe "adding a unit" && {

	context "add unit" && {

		out=$(ign units ruby --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby"
		}
		it "creates script record file" && {
			expect "./input/units/ruby.yaml" to_exist
		}
	}
    
    context "add field enable=true" && {
    
		it "shows updated record" && {
		
			out=$(ign units ruby enabled=true ; echo "<END") ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true" \
								"<END" # verify no trailing empty line 
		}     	 	
	}

	context "add unit contents" && {
    
		it "shows updated record - with contents" && {
		
			out=$(ign units ruby "contents=test\nthis\n"; echo "<END") ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true" \
								"  contents: |" \
								"    test" \
								"    this" \
								"" \
								"<END" #verify trailing empty line 
		}     	 	    	 	
	}	
    context "add field mask=true" && {
    
		it "shows updated record" && {
		
			out=$(ign units ruby mask=true ; echo "<END") ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true" \
								"  mask: true" \
								"  contents: |" \
								"    test" \
								"    this" \
								"" \
								"<END" #verify trailing empty line 
		}     	 	
	}
	context "add unit contents_file" && {
    
		it "shows updated record - with contents" && {
			
			out=$(ign units ruby "contents_file=test.service"; echo "<END") ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true" \
								"  mask: true" \
								"  contents: |" \
								"    to be" \
								"    or not" \
								"    to be" \
								"<END" #verify trailing empty line
		}     	 	    	 	
	}		
    context "remove field mask=" && {
    
		it "shows updated record" && {
		
			out=$(ign units ruby mask= ; echo "<END") ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true" \
								"  contents: |" \
								"    to be" \
								"    or not" \
								"    to be" \
								"<END" #verify trailing empty line
		}    	 	
	}
	
 	context "remove contents" && {
    
		it "shows updated record" && {
		
			out=$(ign units ruby contents=) ; should_succeed
		
			expect "$out" to_be "ruby.yaml" \
								"systemd.units[+]:" \
								"  name: ruby" \
								"  enabled: true"
		}    	 	
	}

}

describe "deleting a unit" && {
	context "ign units ruby --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign units ruby --delete) ; should_succeed
		
			expect "$out" to_match "Moved ruby.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/units/ruby.yaml" not to_exist
		}
	}
	context "ign units --list" && {
		it "should report ''" && {
			out=$(ign units --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}

 