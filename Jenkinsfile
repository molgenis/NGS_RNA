node {
	stage ('Checkout') {
		checkout scm
	}
        stage ('Automated test') {
        
        echo "Copy test from repo to molgenis home on Talos"
        sh "sudo scp test/test_pipeline.sh reception+talos:/home/umcg-molgenis/test_pipeline_RNA.sh"
        
        echo "Login to Talos"
	    
	sh '''
            sudo ssh -tt reception+talos 'exec bash -l << 'ENDSSH'
	    	echo "Starting automated test"
		bash /home/umcg-molgenis/test_pipeline_RNA.sh '''+env.CHANGE_ID+'''
ENDSSH'
        '''	
	}
}
