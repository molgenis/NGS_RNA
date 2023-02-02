node {
	stage ('Checkout') {
		checkout scm
	}
        stage ('Automated test') {
        
        echo "Copy test from repo to molgenis home on HC-DAI"
        sh "sudo scp test/test_pipeline.sh portal+hc-dai:/home/umcg-molgenis/test_pipeline_RNA.sh"
        
        echo "Login to HC-DAI"
	    
	sh '''
            sudo ssh -tt portal+hc-dai 'exec bash -l << 'ENDSSH'
	    	echo "Starting automated test"
		bash /home/umcg-molgenis/test_pipeline_RNA.sh '''+env.CHANGE_ID+'''
ENDSSH'
        '''	
	}
}
