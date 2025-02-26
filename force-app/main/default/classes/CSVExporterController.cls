/**
 * Apex controller for CSV Exporter LWC
 */
public without sharing class CSVExporterController {
    
    /**
     * Get field metadata for the specified object
     * @param objectName API name of the object
     * @return List of field information
     */
    @AuraEnabled(cacheable=true)
    public static List<FieldInfo> getFields(String objectName) {
        List<FieldInfo> fields = new List<FieldInfo>();
        
        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                // Skip fields that shouldn't be exposed
                if (fieldDescribe.isAccessible() && !fieldDescribe.isCalculated() && 
                    !fieldDescribe.isAutoNumber() && !fieldName.endsWith('__r')) {
                    fields.add(new FieldInfo(
                        fieldDescribe.getLabel(),
                        fieldDescribe.getName(),
                        String.valueOf(fieldDescribe.getType())
                    ));
                }
            }
            
            fields.sort();
            return fields;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving field information: ' + e.getMessage());
        }
    }
    
    /**
     * Get records based on specified fields, with batching support
     * @param objectName API name of the object
     * @param fields List of field API names to retrieve
     * @param batchSize Number of records to retrieve per batch
     * @param offset Starting offset for the query
     * @return RecordResult containing records and count
     */
    @AuraEnabled
    public static RecordResult getRecords(String objectName, List<String> fields, Integer batchSize, Integer offset) {
        RecordResult result = new RecordResult();
        
        try {
            // Ensure we're working with a manageable batch size
            Integer limitedBatchSize = Math.min(batchSize, 2000);
            
            // Create query
            String query = 'SELECT ' + String.join(fields, ', ') + 
                           ' FROM ' + objectName + 
                           ' LIMIT ' + limitedBatchSize + 
                           ' OFFSET ' + offset;
            
            System.System.debug('Query: ' + query);
            // Execute query with security enforced
            List<SObject> records = Database.query(String.escapeSingleQuotes(query));
            
            // Convert SObjects to maps for easy serialization
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
            for (SObject record : records) {
                Map<String, Object> recordMap = new Map<String, Object>();
                
                // Add each field to the map
                for (String field : fields) {
                    recordMap.put(field, record.get(field));
                }
                
                recordMaps.add(recordMap);
            }
            
            result.records = recordMaps;
            System.System.debug('recordMaps: ' + recordMaps);
            result.totalCount = Database.countQuery('SELECT COUNT() FROM ' + objectName );
            
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving records: ' + e.getMessage());
        }
    }
    
    /**
     * FieldInfo wrapper class to return field metadata
     */
    public class FieldInfo implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public String dataType;
        
        public FieldInfo(String label, String apiName, String dataType) {
            this.label = label;
            this.apiName = apiName;
            this.dataType = dataType;
        }
        
        // Implement the compareTo method for sorting
        public Integer compareTo(Object compareTo) {
            FieldInfo compareToField = (FieldInfo)compareTo;
            return this.label.compareTo(compareToField.label);
        }
    }
    
    /**
     * RecordResult wrapper class to return records and count
     */
    public class RecordResult {
        @AuraEnabled public List<Map<String, Object>> records;
        @AuraEnabled public Integer totalCount;
        
        public RecordResult() {
            records = new List<Map<String, Object>>();
            totalCount = 0;
        }
    }
}