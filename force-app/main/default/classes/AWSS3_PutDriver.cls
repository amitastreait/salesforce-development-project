public class AWSS3_PutDriver{
    @future(callout = true)
    public static void insertAttachmentTOAWS(Set<Id> attachmentIdsSet, Map<Id, Id> parentIdsMap){
        System.debug('#### Inside Future Method..');
        For(Id id : attachmentIdsSet){
            AWSS3_PutAttachments putAttachment = new AWSS3_PutAttachments();
            putAttachment.recordId = Id;
            putAttachment.parentIdsMap = parentIdsMap;
            putAttachment.init();
        }
    }
}