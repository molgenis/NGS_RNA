pipeline {
	agent any
	stages {
#		stage ('Checkout') {
#			steps {
#				checkout scm
#			}
#		}
        	stage ('Automated test') {
			steps {        
        		echo "Copy test from repo to molgenis home on Hyperchicken"
        		sh "sudo scp test/test_pipeline.sh portal+hyperchicken:/home/umcg-molgenis/test_pipeline_RNA.sh"
        
        		echo "Login to Hyperchicken"
	    
			sh '''
            		sudo ssh -tt portal+hyperchicken 'exec bash -l << 'ENDSSH'
	    			echo "Starting automated test"
				bash /home/umcg-molgenis/test_pipeline_RNA.sh '''+env.CHANGE_ID+'''
   ENDSSH'
        		'''
			}
		}
	}
}
