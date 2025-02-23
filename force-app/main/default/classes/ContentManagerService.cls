/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 12-18-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log  
 * Ver   Date         Author       Modification
 * 1.0   11-26-2020   Amit Singh   Initial Version
**/
public with sharing class ContentManagerService {
    
    @AuraEnabled
    public static String getContentDetails(String recordId) {
        
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                        FROM   ContentDocumentLink 
                                                        WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
            
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
        
        List<FileWrapper> wrapperList = new List<FileWrapper>();
        
        for(ContentVersion version : [SELECT Id, VersionData, FileType, Title, FileExtension,
                                            ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                            CreatedDate, ContentDocumentId, Description__c
                                            FROM   ContentVersion 
                                            WHERE  ContentDocumentId IN : contentDocumentId]){
                                                        
            FileWrapper wrapper 	  = new FileWrapper();
            wrapper.recordId 		  = version.Id;
            wrapper.FileType		  = version.FileType.toLowerCase();
            wrapper.Title			  = version.Title;
            wrapper.FileExtension 	  = version.FileExtension.toLowerCase();
            wrapper.CreatedByName 	  = version.ContentDocument.CreatedBy.Name;
            wrapper.ContentSize	  	  = version.ContentDocument.ContentSize;
            wrapper.CreatedDate	  	  = version.CreatedDate;
            wrapper.ContentDocumentId = version.ContentDocumentId;
            wrapper.Description       = version.Description__c;
            wrapperList.add(wrapper);
        }
        return JSON.serialize(wrapperList);
        
    }

    @AuraEnabled
    public static string getFilesToDownload(List<Id> contentDocumentId){
        
        List<ContentWrapper> wrapperList = new List<ContentWrapper>();

        for(ContentVersion version : [SELECT VersionData, Title, FileExtension FROM ContentVersion 
                                        WHERE  ContentDocumentId IN : contentDocumentId]){
            ContentWrapper wrapper = new ContentWrapper();
            wrapper.fileName = version.Title+'.'+version.FileExtension.toLowerCase();
            wrapper.fileData = EncodingUtil.base64Encode(version.VersionData);
            wrapperList.add(wrapper);
        }
        return JSON.serialize(wrapperList);
    }

    @AuraEnabled
    public static void updateDescription(String description, String documentId){
        try {
            ContentVersion version = [Select Id FROM ContentVersion Where ContentDocumentId =: documentId];
            version.Description__c = description;
            update version;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteContentDocument(String recordId) {
        Database.delete(recordId);
    }
    
    public class FileWrapper {
        @AuraEnabled
        public String recordId 				{ get; set; }
        @AuraEnabled
        public String VersionData 			{ get; set; }
        @AuraEnabled
        public String FileType 				{ get; set; }
        @AuraEnabled
        public String Title 				{ get; set; }
        @AuraEnabled
        public String FileExtension 		{ get; set; }
        @AuraEnabled
        public String CreatedByName 		{ get; set; }
        @AuraEnabled
        public Integer ContentSize 			{ get; set; }
        @AuraEnabled
        public DateTime CreatedDate 		{ get; set; }
        @AuraEnabled
        public String ContentDocumentId 	{ get; set; }
        @AuraEnabled
        public String Description        	{ get; set; }
    }

    public class ContentWrapper {
        @AuraEnabled 
        public String fileName  { get; set; }
        @AuraEnabled
        public String fileData  { get; set; }
    }
}