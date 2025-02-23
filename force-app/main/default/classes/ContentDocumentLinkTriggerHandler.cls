public class ContentDocumentLinkTriggerHandler {

    public static void copyCaseFilesToAccount(Set<Id> linkedEntityIdsSet, Set<Id> contentDocumentLinkIdsSet){
		List<ContentDocumentLink> documentLink = getDocumentLink(linkedEntityIdsSet, contentDocumentLinkIdsSet);
        List<ContentDocumentLink> documentLinkToInsert = new List<ContentDocumentLink>();
        Map<Id, Id> accountIdsMap = new Map<Id, Id>();
        for(Case request : [SELECT Id, AccountId, ContactId FROM CASE WHERE Id IN: linkedEntityIdsSet]){
            accountIdsMap.put(request.Id, request.AccountId);
        }
        for(ContentDocumentLink link : documentLink){
            ContentDocumentLink linkCloned = link.clone(false, false, false, false);
            Id parentId = accountIdsMap.get(link.LinkedEntityId);
            if(parentId != null){
                linkCloned.LinkedEntityId = parentId;
                documentLinkToInsert.add(linkCloned);
            }
        }
        insert documentLinkToInsert;
    }
    public static void copyActivitiesFilesToCase(Set<Id> linkedEntityIdsSet, Set<Id> contentDocumentLinkIdsSet, String objectName){
        List<ContentDocumentLink> documentLinkToInsert = new List<ContentDocumentLink>();
        Map<Id, Id> caseIdsMap = new Map<Id, Id>();
        String query = 'Select Id, WhatId, What.Type From ';
        if(objectName.equals('Task')){
            query += 'Task Where Id IN: linkedEntityIdsSet';
        }else{
            query += 'Event Where Id IN: linkedEntityIdsSet';
        }
        
        for(sObject sobj : Database.query(query)){
            Id whatId = (Id)sobj.get('WhatId');
            Id recordId = (Id)sobj.get('Id');
            if(whatId.getSObjectType() == CASE.sObjectType){
                caseIdsMap.put(recordId, whatId);
            }
        }
        List<ContentDocumentLink> documentLink = getDocumentLink(caseIdsMap.keySet(), contentDocumentLinkIdsSet);
        for(ContentDocumentLink link : documentLink){
            ContentDocumentLink linkCloned = link.clone(false, false, false, false);
            Id parentId = caseIdsMap.get(link.LinkedEntityId);
            if(parentId != null){
                linkCloned.LinkedEntityId = parentId;
                documentLinkToInsert.add(linkCloned);
            }
        }
        insert documentLinkToInsert;
    }
    
    private static List<ContentDocumentLink> getDocumentLink(Set<Id> linkedEntityIdsSet, Set<Id> contentDocumentLinkIdsSet){
        List<ContentDocumentLink> documentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, 
                                                  ShareType, Visibility 
                                                  FROM ContentDocumentLink
                                                  WHERE LinkedEntityId IN : linkedEntityIdsSet
                                                  AND Id IN: contentDocumentLinkIdsSet];
        return documentLink;
    }
}