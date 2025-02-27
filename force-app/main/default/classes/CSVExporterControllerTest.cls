/**
 * Test class for CSVExporterController with relationship field support
 * @author Claude
 * @date 2025-02-26
 */
@isTest
public class CSVExporterControllerTest {
    
    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Phone = '555-555-555' + i,
                BillingCity = 'Test City ' + i,
                Industry = 'Technology',
                AnnualRevenue = 10000 * (i + 1)
            ));
        }
        insert testAccounts;
        
        // Create test contacts linked to accounts
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'test' + i + '@example.com',
                Phone = '555-123-456' + i,
                AccountId = testAccounts[Math.mod(i, testAccounts.size())].Id
            ));
        }
        insert testContacts;
        
        // Create test opportunities linked to accounts
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            testOpportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = testAccounts[i].Id,
                Amount = 5000 * (i + 1)
            ));
        }
        insert testOpportunities;
    }
    
    /**
     * Test retrieving field metadata including relationship fields
     */
    @isTest
    static void testGetFieldsWithRelationships() {
        // Act
        Test.startTest();
        List<CSVExporterController.FieldInfo> fields = CSVExporterController.getFields('Contact');
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, fields, 'Fields should not be null');
        System.assert(fields.size() > 0, 'Should retrieve Contact fields');
        
        // Verify relationship fields exist
        Boolean hasAccountNameField = false;
        String accountNameFieldApi = '';
        
        for (CSVExporterController.FieldInfo field : fields) {
            if (field.apiName.startsWith('Account.') && field.apiName.endsWith('Name')) {
                hasAccountNameField = true;
                accountNameFieldApi = field.apiName;
                // Verify the related ID field property is set
                System.assertEquals('AccountId', field.relatedIdField, 'Related ID field should be set correctly');
            }
        }
        
        System.assert(hasAccountNameField, 'Account Name relationship field should be present');
        System.assert(accountNameFieldApi.equals('Account.Name'), 'Account Name field should have correct API name');
    }
    
    /**
     * Test retrieving records with relationship fields
     */
    @isTest
    static void testGetRecordsWithRelationships() {
        // Arrange
        List<String> fields = new List<String>{'Name', 'Phone', 'Email', 'Account.Name'};
        Integer batchSize = 5;
        Integer offset = 0;
        
        // Act
        Test.startTest();
        CSVExporterController.RecordResult result = CSVExporterController.getRecords('Contact', fields, batchSize, offset);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.records, 'Records should not be null');
        System.assertEquals(5, result.records.size(), 'Should return exactly 5 records (batch size)');
        
        // Verify record fields including relationship fields
        for (Map<String, Object> record : result.records) {
            System.assert(record.containsKey('Name'), 'Record should contain Name field');
            System.assert(record.containsKey('Phone'), 'Record should contain Phone field');
            System.assert(record.containsKey('Email'), 'Record should contain Email field');
            System.assert(record.containsKey('Account.Name'), 'Record should contain Account.Name field');
            System.assert(record.containsKey('AccountId'), 'Record should contain AccountId field');
            
            // Verify relationship values
            String accountName = (String)record.get('Account.Name');
            Id accountId = (Id)record.get('AccountId');
            
            System.assertNotEquals(null, accountName, 'Account Name should not be null');
            System.assertNotEquals(null, accountId, 'Account Id should not be null');
            System.assert(accountName.startsWith('Test Account'), 'Account Name should match expected format');
        }
    }
    
    /**
     * Test retrieving field metadata
     */
    @isTest
    static void testGetFields() {
        // Act
        Test.startTest();
        List<CSVExporterController.FieldInfo> fields = CSVExporterController.getFields('Account');
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, fields, 'Fields should not be null');
        System.assert(fields.size() > 0, 'Should retrieve at least some Account fields');
        
        // Verify known fields exist in the returned list
        Boolean hasNameField = false;
        Boolean hasPhoneField = false;
        for (CSVExporterController.FieldInfo field : fields) {
            if (field.apiName == 'Name') hasNameField = true;
            if (field.apiName == 'Phone') hasPhoneField = true;
        }
        System.assert(hasNameField, 'Name field should be present');
        System.assert(hasPhoneField, 'Phone field should be present');
    }
    
    /**
     * Test retrieving field metadata for invalid object
     */
    @isTest
    static void testGetFieldsInvalidObject() {
        // Act & Assert
        try {
            CSVExporterController.getFields('InvalidObject');
            System.assert(false, 'Should throw an exception for invalid object');
        } catch (AuraHandledException e) {
            
        }
    }
    
    /**
     * Test retrieving records
     */
    @isTest
    static void testGetRecords() {
        // Arrange
        List<String> fields = new List<String>{'Name', 'Phone', 'BillingCity'};
        Integer batchSize = 5;
        Integer offset = 0;
        
        // Act
        Test.startTest();
        CSVExporterController.RecordResult result = CSVExporterController.getRecords('Account', fields, batchSize, offset);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.records, 'Records should not be null');
        System.assertEquals(5, result.records.size(), 'Should return exactly 5 records (batch size)');
        System.assertEquals(5, result.totalCount, 'Total count should be 5 (total test accounts)');
    }
    
    /**
     * Test retrieving records with offset
     */
    @isTest
    static void testGetRecordsWithOffset() {
        // Arrange
        List<String> fields = new List<String>{'Name', 'Phone'};
        Integer batchSize = 5;
        Integer offset = 5; // Skip first 5 records
        
        // Act
        Test.startTest();
        CSVExporterController.RecordResult result = CSVExporterController.getRecords('Contact', fields, batchSize, offset);
        Test.stopTest();
        
        // Assert
        System.assertEquals(5, result.records.size(), 'Should return exactly 5 records (remaining after offset)');
        System.assertEquals(10, result.totalCount, 'Total count should be 10 (total test contacts)');
    }
    
    /**
     * Test FieldInfo class with relationship properties
     */
    @isTest
    static void testFieldInfoWithRelationship() {
        // Arrange
        CSVExporterController.FieldInfo regularField = new CSVExporterController.FieldInfo('Name', 'Name', 'STRING');
        CSVExporterController.FieldInfo relationshipField = new CSVExporterController.FieldInfo(
            'Account Name', 'Account.Name', 'STRING', 'AccountId'
        );
        
        // Assert
        System.assertEquals(null, regularField.relatedIdField, 'Regular field should have null related ID field');
        System.assertEquals('AccountId', relationshipField.relatedIdField, 'Relationship field should have correct related ID field');
    }
}