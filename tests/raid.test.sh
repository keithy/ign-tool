#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${DIR}/bash-spec.sh

# new fixture
cp -a ${DIR}/sandbox.fixture/. /tmp/sandbox.ign # idempotent form of cp
trap "\rm -rf /tmp/sandbox.ign; output_results;" EXIT
cd /tmp/sandbox.ign

# lets go!

describe "when no raid arrays are defined" && {

	context "ign raid" && {
		it "should report 'none defined'" && {

			out=$(ign raid) && should_succeed	 

 			expect $out to_be "none defined"
		}
	}
	
	context "ign raid --list" && {
		it "should report ''" && {

			out=$(ign raid --list) && should_succeed	 

 			expect "$out" to_be ""
		}
	}
	
	context "ign raid anna" && {
		
		it "should report 'anna - not found'" && {
			out=$(ign raid anna) 
 
			expect $out to_be "anna - not found"
		}
		it "does not have script record file" && {
			expect "./input/raid/anna.yaml" not to_exist
		}
	}
	
	context "ign raid anna level=raid5" && {
		
		it "should report 'anna - not found'" && {
			out=$(ign raid anna level=raid5) 
 
			expect $out to_be "anna - not found"
		}
	}	
}

describe "adding a raid" && {

	context "add raid" && {

		out=$(ign raid anna --add) ; should_succeed

		it "shows new script record" && {

			expect "$out" to_be "anna.yaml" \
								"storage.raid[+]:" \
								"  name: anna" \
								"  level: " \
								"  devices: []"
		}
		it "creates script record file" && {
			expect "./input/raid/anna.yaml" to_exist
		}
	}
    
    context "add level" && {
    
		it "shows updated record" && {
		
			out=$(ign raid anna level=raid5) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
								"storage.raid[+]:" \
								"  name: anna" \
								"  level: raid5" \
								"  devices: []"
		}     	 	
	}
	context "add devices" && {

		it "shows raid record with devices as a sub-list " && {
			out=$(ign raid anna devices+=/dev/sda devices+=/dev/sdb options+=opt1) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
									"storage.raid[+]:" \
									"  name: anna" \
									"  level: raid5" \
									"  devices:" \
									"  - /dev/sdb" \
									"  - /dev/sda" \
									"  options:" \
									"  - opt1"
		}
	}
	context "remove device /dev/sdb" && {

		it "shows raid record with devices as a sub-list " && {
			out=$(ign raid anna devices-=/dev/sdb options-=opt1 --add) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
									"storage.raid[+]:" \
									"  name: anna" \
									"  level: raid5" \
									"  devices:" \
									"  - /dev/sda"
		}
	}
	context "remove last device" && {

		it "shows raid record with devices as a sub-list " && {
			out=$(ign raid anna devices-=/dev/sda options-=opt1 --add) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
									"storage.raid[+]:" \
									"  name: anna" \
									"  level: raid5" \
									"  devices: []"
		}
	}	
    context "add spares" && {
    
		it "shows updated record" && {
		
			out=$(ign raid anna spares=1) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
								"storage.raid[+]:" \
								"  name: anna" \
								"  level: raid5" \
								"  devices: []" \
								"  spares: 1"
		}     	 	
	}
	
	context "ign raid --list" && {
    
		it "shows list of names" && {
		
			out=$(ign raid --list) ; should_succeed
		
			expect "$out" to_be "anna"
		}     	 	
	}
}

describe "deleting a raid" && {
	context "ign raid arrays anna --delete" && {
		it "should explain movement of file to trash" && {
		
			out=$(ign raid anna --delete) ; should_succeed
		
			expect "$out" to_match "Moved anna.yaml to /*"
		}
	
		it "file should be gone" && {
			expect "./input/passwd/raid/anna.yaml" not to_exist
		}
	}
	context "ign raid --list" && {
		it "should report ''" && {

			out=$(ign raid --list) ; should_succeed	 

 			expect "$out" to_be ""
		}
	}
}

describe "adding a raid in one line" && {

	context "add raid" && {

		it "shows raid record" && {
			out=$(ign raid anna --add devices+=/dev/sda level=raid1) ; should_succeed
		
			expect "$out" to_be "anna.yaml" \
									"storage.raid[+]:" \
									"  name: anna" \
									"  level: raid1" \
									"  devices:" \
									"  - /dev/sda"
									 
			ign raid anna --delete
		}	 	 
	}
}
