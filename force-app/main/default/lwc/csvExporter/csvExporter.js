// csvExporter.js
import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getRecords from '@salesforce/apex/CSVExporterController.getRecords';
import getFields from '@salesforce/apex/CSVExporterController.getFields';

export default class CsvExporter extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track isLoading = false;
    @api selectedFields = [];
    @track availableFields = [];
    @track error;
    @api showFieldSelect = false;
    @track showFieldSelector = false;
    @track batchSize = 2000;
    @track maxRecords = 50000;
    @track recordsProcessed = 0;

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    connectedCallback() {
        this.loadFields();
    }

    loadFields() {
        this.isLoading = true;
        getFields({ objectName: this.objectApiName })
            .then(result => {
                this.availableFields = result.map(field => ({
                    label: field.label,
                    value: field.apiName,
                    dataType: field.dataType
                }));
                this.isLoading = false;
            })
            .catch(error => {
                this.handleError(error);
                this.isLoading = false;
            });
    }

    handleFieldSelection(event) {
        const selectedOptions = event.detail.value;
        this.selectedFields = selectedOptions;
    }

    toggleFieldSelector() {
        this.showFieldSelector = !this.showFieldSelector;
    }

    async exportCSV() {
        if (this.selectedFields.length === 0) {
            this.showToast('Error', 'Please select at least one field to export', 'error');
            return;
        }

        this.isLoading = true;
        this.recordsProcessed = 0;
        const fieldsList = this.selectedFields;
        
        try {
            let offset = 0;
            let allRecords = [];
            let hasMore = true;

            // Process in batches to handle large data sets
            while (hasMore && this.recordsProcessed < this.maxRecords) {
                const result = await getRecords({
                    objectName: this.objectApiName,
                    fields: fieldsList,
                    batchSize: this.batchSize,
                    offset: offset
                });

                if (result.records && result.records.length > 0) {
                    allRecords = allRecords.concat(result.records);
                    this.recordsProcessed += result.records.length;
                    offset += this.batchSize;
                    
                    // Update progress
                    if (result.records.length < this.batchSize) {
                        hasMore = false;
                    }
                } else {
                    hasMore = false;
                }
            }

            if (allRecords.length > 0) {
                this.downloadCSV(allRecords, fieldsList);
                this.showToast('Success', `Exported ${allRecords.length} records successfully`, 'success');
            } else {
                this.showToast('Info', 'No records found to export', 'info');
            }
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    downloadCSV(records, fields) {
        // Create headers
        let headers = fields.join(',');
        
        // Create CSV content
        let csvContent = records.map(record => {
            return fields.map(field => {
                // Handle null values and escape commas in text
                const value = record[field] != null ? record[field] : '';
                return typeof value === 'string' ? `"${value.replace(/"/g, '""')}"` : value;
            }).join(',');
        }).join('\n');

        // Combine headers and content
        csvContent = headers + '\n' + csvContent;
        
        // Create a download link and trigger download
        const downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        downloadElement.target = '_blank';
        downloadElement.download = `${this.objectApiName}_Export_${new Date().toISOString()}.csv`;
        downloadElement.click();
    }

    handleError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.error = message;
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}