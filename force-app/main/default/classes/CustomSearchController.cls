/**
 * @File Name          : CustomSearchController.cls
 * @Description        : 
 * @Author             : Amit Singh (SFDCPanther)
 * @Group              : 
 * @Last Modified By   : Amit Singh
 * @Last Modified On   : 09-28-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/31/2020   Amit Singh (SFDCPanther)     Initial Version
**/
public with sharing class CustomSearchController {
    
    @AuraEnabled
    public static String searchRecords(String objName, String fieldName, String searchKey, String customerId){
        String searchKeyword = searchKey + '*';
        String returningQuery = '';
        if(!String.isBlank(customerId)){
            returningQuery = objName+' ( Id, '+fieldName+' , '+customerId+
            ' WHERE '+customerId+' != null'+ ')';
        }else{
            returningQuery = objName+' ( Id, '+fieldName+')';
        }

        //System.debug(System.LoggingLevel.DEBUG, ' returningQuery '+ returningQuery);
       
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 2000';
        List<List<sObject>> sobjectList = Search.query(Query);
        return JSON.serialize(sobjectList);
    }

    @AuraEnabled
    public static String searchPriceRecords(String searchKey){
        
        String searchKeyword = '%'+searchKey + '%';

        String returningQuery = 'SELECT Id, Stripe_Product__c, Stripe_Product__r.Name, Amount__c, Price_Id__c, Currency__c, Active__c FROM Product_Price__c Where Stripe_Product__r.Name Like:searchKeyword';

        if(UserInfo.isMultiCurrencyOrganization()){
            returningQuery = 'SELECT Id, Stripe_Product__c, Stripe_Product__r.Name, convertCurrency(Amount__c), Price_Id__c, Currency__c, Cloned_Amount__c, Active__c FROM Product_Price__c Where Stripe_Product__r.Name Like:searchKeyword';
        }
        List<sObject> sobjectList = Database.query(returningQuery);
        
        return JSON.serialize(sobjectList);
    }

}