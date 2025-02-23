/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 12-03-2020
 * @last modified by  : Amit Singh
 * Modifications Log 
 * Ver   Date         : Author       Modification
 * 1.0   12-03-2020   : Amit Singh   Initial Version
**/
@isTest
public with sharing class ContentDocumentUnitTest {

    @IsTest
    static void contentDocumentTest(){

        String firstname = 'Amit';
        String lastName  = 'Singh';

        Id profileId = [Select Id, Name From Profile Where Name = 'System Administrator' Limit 1].Id;
        Id roleId = null;

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User userRecord = new User(  firstname = firstName,
            lastName = lastName,
            email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = profileId
        );
        
        if(!String.isBlank(roleId)){
            userRecord.UserRoleId = roleId;
        }

        Account accRecord = new Account(
            Name = 'The Pepsico Company',
            Rating = 'Hot'
        );

        insert accRecord;
        
        Test.startTest();
        System.runAs(userRecord){
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = accRecord.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;

            System.assertEquals(contentlink.ContentDocumentId,contentVersion_2.ContentDocumentId );
        }
        Test.stopTest();
        
    }
}