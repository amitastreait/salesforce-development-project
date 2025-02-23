/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 03-18-2021
 * @last modified by  : Amit Singh
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   03-18-2021   Amit Singh   Initial Version
**/
import { api, LightningElement, track, wire } from 'lwc';
import getContentDetails from '@salesforce/apex/ContentManagerService.getContentDetails';
import deleteContentDocument from '@salesforce/apex/ContentManagerService.deleteContentDocument';
import updateDescription from '@salesforce/apex/ContentManagerService.updateDescription';
import getFilesToDownload from '@salesforce/apex/ContentManagerService.getFilesToDownload';

import { NavigationMixin } from 'lightning/navigation';

const actions = [
    {  label: 'Preview',   name: 'Preview'  },
    {  label: 'Download',  name: 'Download' },
    {  label: 'Delete',    name: 'Delete'   },
    {  label: 'Update',    name: 'Update'   }
]
const columns = [
    { label: 'Title',       fieldName: 'Title', wrapText : true,sortable: true,
        cellAttributes: { 
            iconName: { fieldName: 'icon' }, iconPosition: 'left' 
        }
    },
    { label: 'Description',    fieldName: 'Description', wrapText : true},
    { label: 'Created By',  fieldName: 'CREATED_BY',sortable: true,
        cellAttributes: { 
            iconName: 'standard:user', iconPosition: 'left', size : 'large'
        }
    },
    { label: 'File Size',   fieldName: 'Size',sortable: true },
    { type: 'action', typeAttributes: { rowActions: actions } }
];

export default class ContentManager extends NavigationMixin(LightningElement) {

    @api title;
    @api showDetails;
    @api showFileUpload;
    @api showsync;
    @api recordId;
    @api usedInCommunity;
    @api showFilters;
    @api accept = '.csv,.doc,.xsl,.pdf,.png,.jpg,.jpeg,.docx,.doc';

    @track dataList;
    @track columnsList = columns;
    isLoading = false;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    showModal = false;
    description;
    disabled = true;

    documentIds = [];

    formats = ['font', 'size', 'bold', 'italic', 'underline',
        'strike', 'list', 'indent', 'align', 'link',
        'image', 'clean', 'table', 'header', 'color'];

    _filteredRecord;
    _data;

    connectedCallback() {
        this.handleSync();
    }

    getBaseUrl(){
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    }

    handleChangeText(event){
        this.description = event.target.value;
        if(this.description){
            this.disabled = false;
        }else{
            this.disabled = true;
        }
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Download':
                this.downloadFile(row);
                break;
            case 'Delete':
                this.handleDeleteFiles(row);
                break;
            case 'Update':
                this.handleUpdate(row);
                break;
            default:
        }
    }

    handleUpdate(row){
        window.console.log( JSON.stringify(row) );
    }

    previewFile(file){
        
        if(!this.usedInCommunity){
            
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    selectedRecordId: file.ContentDocumentId
                }
            });

        } else if(this.usedInCommunity){
            
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.fileUrl
                }
            }, false );
        }
        
    }

    downloadFile(file){
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: file.downloadUrl
                }
            }, false 
        );
    }

    handleDeleteFiles(row){

        this.isLoading = true;

        deleteContentDocument({
            recordId : row.ContentDocumentId
        })
        .then(result => {
            this.dataList  = this.dataList.filter(item => {
                return item.ContentDocumentId !== row.ContentDocumentId ;
            });
        })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })
        .finally(()=>{
            this.isLoading = false;
        });
    }

    handleSync(){

        let imageExtensions = ['png','jpg','gif'];
        let supportedIconExtensions = ['ai','attachment','audio','box_notes','csv','eps','excel','exe','docx',
                        'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder',
                        'link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide',
                        'rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];

        this.isLoading = true;
        getContentDetails({
            recordId : this.recordId
        })
        .then(result => {

            let parsedData       = JSON.parse(result);
            let stringifiedData  = JSON.stringify(parsedData);
            let finalData        = JSON.parse(stringifiedData);
            let baseUrl          = this.getBaseUrl();

            finalData.forEach(file => {
                file.downloadUrl = baseUrl+'sfc/servlet.shepherd/document/download/'+file.ContentDocumentId;
                file.fileUrl     = baseUrl+'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.recordId;
                file.CREATED_BY  = file.CreatedByName;
                file.Size        = this.formatBytes(file.ContentSize, 2);
                let fileType     = file.FileType.toLowerCase();
                if(imageExtensions.includes(fileType)){
                    file.icon    = 'doctype:image';
                }else{
                    if(supportedIconExtensions.includes(fileType)){
                        file.icon = 'doctype:' + fileType;
                    }
                }
                this.documentIds.push(file.ContentDocumentId);
            });
            this._data = finalData;
            this._filteredRecord = this._data;
            window.console.log(' this._data ', this._data);
        })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })
        .finally(()=>{
            this.isLoading = false;
        });
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        updateDescription({ 
            description : this.description,
            documentId  :  uploadedFiles[0].documentId
        })
        .then(result => {
            console.log('Result', result);
            this.handleSync();
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
    @api
    downloadAll(){

        this.isLoading = true;
        let dataList;

        window.console.log('**** this.documentIds \n ', this.documentIds);

        getFilesToDownload({
            contentDocumentId : this.documentIds
        })
        .then(result => {

            let stringifiedData  = JSON.stringify(result);
            let finalData        = JSON.parse(stringifiedData);
            dataList             = finalData;
            return dataList;
        })
        .catch(error => {
            console.error(' **** error **** \n ', error );
        })
        .finally(()=>{
            this.isLoading = false;
        });

        return this.dataList;
    }
    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    handleModal(){
        this.showModal = true;
    }
    closeModal(){
        this.showModal = false;
    }
    /*
    handleSearch(event){
        let value = event.target.value;
        let name  = event.target.name;
        if( name === 'Title' ){
            this.dataList = this.dataList.filter( file => {
                return file.Title.toLowerCase().includes(value.toLowerCase());
            });
        } else if( name === 'Created By' ){
            this.dataList = this.dataList.filter( file => {
                return file.CREATED_BY.toLowerCase().includes(value.toLowerCase());
            });
        }
    }*/

    handleSearch(event){
        let _searchVar  = event.target.value;
        let _dataList   = this._data;
        let _filterList = [];
        window.console.log(' _searchVar ', _searchVar);
        if(_searchVar){
            _filterList = this.arrayContainsValue(_dataList,_searchVar);
        }else{
            _filterList = this._data;
        }
        window.console.log(' _filterList ', _filterList);
        this._filteredRecord = _filterList;
    }
    arrayContainsValue(arr, val){
        window.console.log(' val ', val);
        window.console.log(' arr ', arr);
        var records=[];
        var _regex = new RegExp(val, "i");
        for (var i = 0; i < arr.length; i++) {
            for (var key in arr[i]){
                if( arr[i][key].search( _regex ) !== -1 ){
                    records.push(arr[i]);
                    break;
                }
            }
        }
        window.console.log(' records ', records);
        return records;
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                return primer(x[field]);
            }
            : function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.dataList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.dataList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}