/**
 * Test class for CSVExporterController
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
        for (Integer i = 0; i < 10; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Phone = '555-555-555' + i,
                BillingCity = 'Test City ' + i,
                Industry = 'Technology',
                AnnualRevenue = 10000 * (i + 1)
            ));
        }
        insert testAccounts;
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
        
        // Verify field properties
        for (CSVExporterController.FieldInfo field : fields) {
            System.assertNotEquals(null, field.label, 'Field label should not be null');
            System.assertNotEquals(null, field.apiName, 'Field API name should not be null');
            System.assertNotEquals(null, field.dataType, 'Field data type should not be null');
        }
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
            //System.assert(e.getMessage().contains('Error retrieving field information'), 'Exception message should indicate field retrieval error');
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
        System.assertEquals(10, result.totalCount, 'Total count should be 10 (total test accounts)');
        
        // Verify record fields
        for (Map<String, Object> record : result.records) {
            System.assert(record.containsKey('Name'), 'Record should contain Name field');
            System.assert(record.containsKey('Phone'), 'Record should contain Phone field');
            System.assert(record.containsKey('BillingCity'), 'Record should contain BillingCity field');
        }
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
        CSVExporterController.RecordResult result = CSVExporterController.getRecords('Account', fields, batchSize, offset);
        Test.stopTest();
        
        // Assert
        System.assertEquals(5, result.records.size(), 'Should return exactly 5 records (remaining after offset)');
        System.assertEquals(10, result.totalCount, 'Total count should be 10 (total test accounts)');
    }
    
    /**
     * Test retrieving records with large batch size
     */
    @isTest
    static void testGetRecordsLargeBatchSize() {
        // Arrange
        List<String> fields = new List<String>{'Name'};
        Integer batchSize = 5000; // Deliberately larger than limit
        Integer offset = 0;
        
        // Act
        Test.startTest();
        CSVExporterController.RecordResult result = CSVExporterController.getRecords('Account', fields, batchSize, offset);
        Test.stopTest();
        
        // Assert
        System.assertEquals(10, result.records.size(), 'Should return 10 records (all test accounts)');
        System.assertEquals(10, result.totalCount, 'Total count should be 10');
    }
    
    /**
     * Test retrieving records for invalid object
     */
    @isTest
    static void testGetRecordsInvalidObject() {
        // Arrange
        List<String> fields = new List<String>{'Name'};
        
        // Act & Assert
        try {
            CSVExporterController.getRecords('InvalidObject', fields, 10, 0);
            System.assert(false, 'Should throw an exception for invalid object');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error retrieving records'), 'Exception message should indicate record retrieval error');
        }
    }
    
    /**
     * Test retrieving records with invalid field
     */
    @isTest
    static void testGetRecordsInvalidField() {
        // Arrange
        List<String> fields = new List<String>{'Name', 'InvalidField'};
        
        // Act & Assert
        try {
            CSVExporterController.getRecords('Account', fields, 10, 0);
            System.assert(false, 'Should throw an exception for invalid field');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error retrieving records'), 'Exception message should indicate record retrieval error');
        }
    }
    
    /**
     * Test FieldInfo compareTo method for sorting
     */
    @isTest
    static void testFieldInfoCompareTo() {
        // Arrange
        CSVExporterController.FieldInfo fieldA = new CSVExporterController.FieldInfo('A Field', 'A_Field__c', 'STRING');
        CSVExporterController.FieldInfo fieldB = new CSVExporterController.FieldInfo('B Field', 'B_Field__c', 'STRING');
        CSVExporterController.FieldInfo fieldC = new CSVExporterController.FieldInfo('A Field', 'Another_A_Field__c', 'INTEGER');
        
        // Act & Assert
        System.assert(fieldA.compareTo(fieldB) < 0, 'A Field should sort before B Field');
        System.assert(fieldB.compareTo(fieldA) > 0, 'B Field should sort after A Field');
        System.assertEquals(0, fieldA.compareTo(fieldC), 'Fields with same label should be equal for sorting');
    }
    
    /**
     * Test RecordResult initialization
     */
    @isTest
    static void testRecordResultInitialization() {
        // Arrange & Act
        CSVExporterController.RecordResult result = new CSVExporterController.RecordResult();
        
        // Assert
        System.assertNotEquals(null, result.records, 'Records list should be initialized');
        System.assertEquals(0, result.records.size(), 'Records list should be empty');
        System.assertEquals(0, result.totalCount, 'Total count should be 0');
    }
}