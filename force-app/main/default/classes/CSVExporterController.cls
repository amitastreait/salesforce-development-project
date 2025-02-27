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
            Map<String, Map<String, String>> relationshipFields = new Map<String, Map<String, String>>();
            
            // First pass: collect all fields and identify relationship fields
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                // Skip fields that shouldn't be exposed
                if (!fieldDescribe.isAccessible()) {
                    continue;
                }
                
                // Regular fields (non-relationship)
                if (!fieldDescribe.isCalculated() && !fieldDescribe.isAutoNumber()) {
                    fields.add(new FieldInfo(
                        fieldDescribe.getLabel(),
                        fieldDescribe.getName(),
                        String.valueOf(fieldDescribe.getType())
                    ));
                }
                
                // Capture reference fields for adding parent fields later
                if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE && !fieldName.endsWith('__r')) {
                    // Get the relationship name and reference to object
                    List<Schema.SObjectType> referencedObjects = fieldDescribe.getReferenceTo();
                    if (!referencedObjects.isEmpty()) {
                        String relationshipName = fieldDescribe.getRelationshipName();
                        String referencedObjectName = referencedObjects[0].getDescribe().getName();
                        if (relationshipName != null && referencedObjectName != null) {
                            // Store relationship information
                            Map<String, String> relationInfo = new Map<String, String>{
                                'fieldId' => fieldDescribe.getName(),
                                'objectName' => referencedObjectName
                            };
                            relationshipFields.put(relationshipName, relationInfo);
                        }
                    }
                }
            }
            
            // Second pass: add parent object name fields
            for (String relationshipName : relationshipFields.keySet()) {
                Map<String, String> relationInfo = relationshipFields.get(relationshipName);
                String parentObjectName = relationInfo.get('objectName');
                String idFieldName = relationInfo.get('fieldId');
                
                // Get the Name field or similar for the parent object
                try {
                    Map<String, Schema.SObjectField> parentFieldMap = Schema.getGlobalDescribe().get(parentObjectName).getDescribe().fields.getMap();
                    for (String parentFieldName : parentFieldMap.keySet()) {
                        Schema.DescribeFieldResult parentFieldDescribe = parentFieldMap.get(parentFieldName).getDescribe();
                        
                        // Add the Name or similar field from parent object
                        if (parentFieldDescribe.isNameField() && parentFieldDescribe.isAccessible()) {
                            // Add relationship field with proper naming
                            String relatedFieldApiName = relationshipName + '.' + parentFieldDescribe.getName();
                            String label = parentObjectName + ' ' + parentFieldDescribe.getLabel();
                            
                            fields.add(new FieldInfo(
                                label,
                                relatedFieldApiName,
                                String.valueOf(parentFieldDescribe.getType()),
                                idFieldName // Store the original ID field name for reference
                            ));
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error getting parent fields for ' + parentObjectName + ': ' + e.getMessage());
                    // Skip this relationship field if there's an error
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
            
            // Process fields to handle relationship fields
            Set<String> queryFields = new Set<String>();
            Map<String, String> relationshipFieldMap = new Map<String, String>();
            
            for (String field : fields) {
                // Handle relationship fields
                if (field.contains('.')) {
                    queryFields.add(field);
                    // Extract the ID field for later mapping
                    List<String> parts = field.split('\\.');
                    if (parts.size() == 2) {
                        String relationshipName = parts[0];
                        relationshipFieldMap.put(field, relationshipName);
                    }
                } else {
                    queryFields.add(field);
                }
            }
            
            // Create query
            String query = 'SELECT ' + String.join(new List<String>(queryFields), ', ') + 
                           ' FROM ' + objectName + 
                           ' LIMIT ' + limitedBatchSize + 
                           ' OFFSET ' + offset;
            
            System.debug('Query: ' + query);
            // Execute query
            List<SObject> records = Database.query(String.escapeSingleQuotes(query));
            
            // Convert SObjects to maps for easy serialization
            List<Map<String, Object>> recordMaps = new List<Map<String, Object>>();
            for (SObject record : records) {
                Map<String, Object> recordMap = new Map<String, Object>();
                
                // Add each field to the map
                for (String field : fields) {
                    if (field.contains('.')) {
                        // Handle relationship fields
                        List<String> parts = field.split('\\.');
                        if (parts.size() == 2) {
                            String relationshipName = parts[0];
                            String fieldName = parts[1];
                            
                            // Get the parent object
                            SObject parentObj = record.getSObject(relationshipName);
                            
                            // Get the value if parent exists
                            Object value = (parentObj != null) ? parentObj.get(fieldName) : null;
                            recordMap.put(field, value);
                            
                            // Also include the ID field
                            String relationshipIdField = relationshipName.endsWith('__r') 
                                ? relationshipName.substring(0, relationshipName.length() - 3) + '__c'
                                : relationshipName + 'Id';
                            
                            // Add ID field if not already added
                            if (!recordMap.containsKey(relationshipIdField)) {
                                recordMap.put(relationshipIdField, record.get(relationshipIdField));
                            }
                        }
                    } else {
                        recordMap.put(field, record.get(field));
                    }
                }
                
                recordMaps.add(recordMap);
            }
            
            result.records = recordMaps;
            result.totalCount = Database.countQuery('SELECT COUNT() FROM ' + objectName);
            
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
        @AuraEnabled public String relatedIdField; // To store the original ID field name for relationship fields
        
        public FieldInfo(String label, String apiName, String dataType) {
            this.label = label;
            this.apiName = apiName;
            this.dataType = dataType;
            this.relatedIdField = null;
        }
        
        public FieldInfo(String label, String apiName, String dataType, String relatedIdField) {
            this.label = label;
            this.apiName = apiName;
            this.dataType = dataType;
            this.relatedIdField = relatedIdField;
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