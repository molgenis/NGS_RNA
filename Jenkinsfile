def finished_first = null

parallel(
    Talos: {
        node {
            try {
            	stage ('Checkout') {
					checkout scm
				}
    				stage ('Automated test') {
        
        				echo "Copy test from repo to molgenis home on Talos"
        				sh "sudo scp test/run_tests.sh reception+talos:/home/umcg-molgenis/"
        
        				echo "Login to Talos"
	    
				sh '''
            			sudo ssh -tt reception+talos 'exec bash -l << 'ENDSSH'
	    					echo "Starting automated test"
					bash /home/umcg-molgenis/run_tests.sh -p '''+env.CHANGE_ID+'''
ENDSSH'
        '''	
	}

                if (finished_first == null) {
                    finished_first = 'Talos'
                    echo "finished_first: ${finished_first}"
                }
            } catch (e) {
                echo "Talos failed"
            }
        }
    },

    Hyperchicken: {
        node {
            try {
            	stage ('Checkout') {
					checkout scm
				}
    				stage ('Automated test') {
        
        				echo "Copy test from repo to molgenis home on Hyperchicken"
        				sh "sudo scp test/run_tests.sh portal+hyperchicken:/home/umcg-molgenis/"
        
        				echo "Login to Hyperchicken"
	    
				sh '''
            			sudo ssh -tt portal+hyperchicken 'exec bash -l << 'ENDSSH'
	    					echo "Starting automated test"
					bash /home/umcg-molgenis/run_tests.sh -p '''+env.CHANGE_ID+'''
ENDSSH'
        '''
	}

                if (finished_first == null) {
                    finished_first = 'Hyperchicken'
                    echo "finished_first: ${finished_first}"
                }
            } catch (e) {
                echo "Hyperchicken failed"
            }
        }
    }
)

if (finished_first) {
    echo "First server to succeed: ${finished_first}"
} else {
    error("Both servers failed")
}
