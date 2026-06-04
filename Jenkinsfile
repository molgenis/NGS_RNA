node {
	stage ('Checkout') {
		checkout scm
	}
        stage ('Automated test') {
        
        echo "Copy tests from repo to molgenis home on Talos"
        sh "sudo scp test/run_tests.sh reception+talos:/home/umcg-molgenis/run_tests.sh"
        
        echo "Login to Talos"
	    
	sh '''
            sudo ssh -tt reception+talos 'exec bash -l << 'ENDSSH'
	    	echo "Starting automated tests"
		bash /home/umcg-molgenis/run_tests.sh -p '''+env.CHANGE_ID+'''
ENDSSH'
        '''	
	}
}
