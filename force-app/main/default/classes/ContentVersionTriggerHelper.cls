public class ContentVersionTriggerHelper {

    public static void uploadFileToAws(List<ContentVersion> contentVersionList, Map<Id, ContentVersion> newRecordMap){
        Map<Id, Id> contentDocumentLinkMap = getContentDocumentLinkMap(contentVersionList);
        AWSS3_PutDriver.insertAttachmentTOAWS(newRecordMap.keySet(), contentDocumentLinkMap);
    }
    public static Map<Id, Id> getContentDocumentLinkMap(List<ContentVersion> contentVersionList){
        Set<String> contentDocumentIdsSet = new Set<String>();
        for(ContentVersion version : contentVersionList){
            contentDocumentIdsSet.add(version.ContentDocumentId);
        }
        Map<Id, Id> contentDocumentLinkMap = new Map<Id, Id>();
        for(ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink
                                        WHERE ContentDocumentId IN :contentDocumentIdsSet]){
            if(link.LinkedEntityId.getSObjectType() == Case.sObjectType
                || link.LinkedEntityId.getSObjectType() == Account.sObjectType
                || link.LinkedEntityId.getSObjectType() == Contact.sObjectType
                || link.LinkedEntityId.getSObjectType() == Opportunity.sObjectType
                || link.LinkedEntityId.getSObjectType() == Lead.sObjectType
                || link.LinkedEntityId.getSObjectType() == Contract.sObjectType
                || link.LinkedEntityId.getSObjectType() == Order.sObjectType){
                    contentDocumentLinkMap.put(link.ContentDocumentId, link.LinkedEntityId);
            }
        }
        return contentDocumentLinkMap;
    }
}