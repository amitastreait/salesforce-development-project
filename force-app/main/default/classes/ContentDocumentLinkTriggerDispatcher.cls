public class ContentDocumentLinkTriggerDispatcher {
    
    public static void run(){
        Set<Id> linkedEntityIdsSet = new Set<Id>();
        Set<Id> contentDocumentLinkIdsSet = new Set<Id>();
        String objectName = '';
        for(ContentDocumentLink link : (List<ContentDocumentLink>)Trigger.New){
            if(link.LinkedEntityId.getSObjectType() == CASE.sObjectType){
                objectName = 'Case';
            }else if(link.LinkedEntityId.getSObjectType() == Task.sObjectType){
                objectName = 'Task';
            }else if(link.LinkedEntityId.getSObjectType() == Event.sObjectType){
                objectName = 'Event';
            }
            if(!String.isBlank(objectName)){
                linkedEntityIdsSet.add(link.LinkedEntityId);
                contentDocumentLinkIdsSet.add(link.Id);
            }
        }
        
        if(linkedEntityIdsSet.isEmpty() == false && !String.isBlank(objectName) && objectName.equals('Case') ){
            ContentDocumentLinkTriggerHandler.copyCaseFilesToAccount(linkedEntityIdsSet, contentDocumentLinkIdsSet);
        }
        if(linkedEntityIdsSet.isEmpty() == false && !String.isBlank(objectName) && ( objectName.equals('Task') || objectName.equals('Event'))){
            ContentDocumentLinkTriggerHandler.copyActivitiesFilesToCase(linkedEntityIdsSet, contentDocumentLinkIdsSet, objectName);
        }
    }
}