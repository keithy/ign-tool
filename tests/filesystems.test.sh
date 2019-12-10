#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no filesystems are defined" && {

	context "ign filesystems" && {
		it "should report 'none defined'" && {

			out=$(ign filesystems) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign filesystems --list" && {
		it "should report ''" && {

			out=$(ign filesystems --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign filesystems root" && {
		
		it "should report 'root - not found'" && {
			out=$(ign filesystems root) 
 
			expect $out to_be "root - not found"
		}
		it "does not have script record file" && {
			expect "./input/filesystems/root.yaml" not to_exist
		}
	}
	
	context "ign filesystems root path=/var/sysroot" && {
		
		it "should report 'root - not found'" && {
			out=$(ign filesystems root path=/var/sysroot) 
 
			expect $out to_be "root - not found"
		}
	}	
}

describe "adding a filesystem" && {

	context "add filesystem" && {

		out=$(ign filesystems root --add) ; should_succeed

		it "shows new filesystems script record" && {

			expect "$out" to_be "root.yaml" \
								"storage.filesystems[+]:" \
								"  path: " \
								"  device: " \
								"  format: "
		}
		it "creates script record file" && {
			expect "./input/filesystems/root.yaml" to_exist
		}
	}
    
    ## Note in this test device has a dash in it on purpose 
    ## because previously - options reading/writing would get confused due to the dash
    
    context "add path device and format" && {
    
		it "shows updated record" && {
		
			out=$(ign filesystems root path=/var/sysroot device=/dev/disk/by-partlabel/var format=ext3) ; should_succeed
		
			expect "$out" to_be "root.yaml" \
								"storage.filesystems[+]:" \
								"  path: /var/sysroot" \
								"  device: /dev/disk/by-partlabel/var" \
								"  format: ext3" 
		}     	 	
	}

    context "add list-item option" && {
    
		it "shows updated record" && {
		
			out=$(ign filesystems root options+=--option) ; should_succeed
		
			expect "$out" to_be "root.yaml" \
								"storage.filesystems[+]:" \
								"  path: /var/sysroot" \
								"  device: /dev/disk/by-partlabel/var" \
								"  format: ext3" \
								"  options:" \
								"  - --option"
		}
	}

   context "just re-read record" && {
 			
		it "shows same record" && {
		
			out=$(ign filesystems root) ; should_succeed
		
			expect "$out" to_be "root.yaml" \
								"storage.filesystems[+]:" \
								"  path: /var/sysroot" \
								"  device: /dev/disk/by-partlabel/var" \
								"  format: ext3" \
								"  options:" \
								"  - --option"
		}     	 	     	 	
	}
	
	context "remove list-item option" && {
    
		it "shows updated record" && {
		
			out=$(ign filesystems root options-=--option) ; should_succeed
		
			expect "$out" to_be "root.yaml" \
								"storage.filesystems[+]:" \
								"  path: /var/sysroot" \
								"  device: /dev/disk/by-partlabel/var" \
								"  format: ext3"
		}  	 	
	}
	
 }

describe "deleting a filesystem" && {
	context "ign filesystems root --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign filesystems root --delete) ; should_succeed
		
			expect "$out" to_match "Moved root.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/filesystems/root.yaml" not to_exist
		}
	}
	context "ign filesystems --list" && {
		it "should report ''" && {
			out=$(ign filesystems --list) ; should_succeed	 
 			expect "$out" to_be ""
		}
	}
}

 