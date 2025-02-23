({
    scriptsLoaded  : function(component, event, helper) {

    },
    handleDownload : function(component, event, helper) {
        
        component.set('v.isLoading', true);
        let childComp  = component.find('contentManager');
        let allRecords = childComp.downloadAll();

        var zipFile = new JSZip();
		
        allRecords.forEach(file => {
            zipFile.file(
            	file.fileName, 
            	file.fileData, 
            	{ base64 : true }
            );
        });
    
    	zipFile.generateAsync( { type:'blob' } ).then(function(content) {
            saveAs(content, 'AllFiles.zip');
    		component.set('v.isLoading', false);
        });

    },
})