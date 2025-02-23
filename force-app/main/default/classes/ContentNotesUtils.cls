/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Amit Singh
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   12-03-2020   Amit Singh   Initial Version
**/
@isTest
public with sharing class ContentNotesUtils {
    
    @IsTest
    public static void contentNoteTest(){

        Account accRecord = new Account(
            Name = 'The Pepsico Company',
            Rating = 'Hot'
        );

        insert accRecord;
        

        /* 
            Approach 1 :
            Use FileExtension as  '.sonte' when creating the Content Note using ContentVersion Object.
        */

        ContentVersion objCntNote = new ContentVersion();
        objCntNote.Title = 'Test Content Note by sfdcpanther.com';
        objCntNote.PathOnClient = objCntNote.Title + '.snote';
        objCntNote.VersionData = Blob.valueOf('Test Content Note by sfdcpanther.com');
        objCntNote.FirstPublishLocationId = accRecord.Id;  // ParentId
        insert objCntNote;
        System.debug('Content Note Id **** \n '+objCntNote);
        

        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = 'Test Content Note by sfdcpanther.com Approach 2';
        String body        = 'Test Content Note by sfdcpanther.com Approach 2';
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        insert noteRecord;

        Test.startTest();
            ContentDocumentLink link2 = new ContentDocumentLink();
            link2.ContentDocumentId   = noteRecord.id;
            link2.LinkedEntityId      = accRecord.Id;//userInfo.getOrganizationId();
            link2.ShareType           = 'V';
            link2.Visibility          = 'AllUsers';
            insert link2;
        Test.stopTest();
        
    }
    
}