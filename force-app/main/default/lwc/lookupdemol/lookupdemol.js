/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 12-29-2021
 * @last modified by  : Amit Singh
**/
import { LightningElement } from 'lwc';

export default class Lookupdemol extends LightningElement {
    fieldsToCreate = ['Name','Rating','Phone','Industry']
    fields        = ['Name'];
    handleLookup = (event) => {
        let data = event.detail.data;
        if(data && data.record){
            // populate the selected record in the correct parent Id field
            // this.allRecord[data.index][data.parentAPIName] = data.record.Id;
        }else{
            // clear the parent Id field
            //this.allRecord[data.index][data.parentAPIName] = undefined;
        }
    }
}