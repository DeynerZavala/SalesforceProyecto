import { LightningElement, api} from 'lwc';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import getRecordTypes from '@salesforce/apex/CaseController.getCaseRecordTypes'
export default class CaseForm extends LightningElement {
    fields  = [SUBJECT_FIELD.fieldApiName,PRIORITY_FIELD.fieldApiName,DESCRIPTION_FIELD.fieldApiName];
    @api recordId;
    recordOptions;
    recordTypeId;
    desactivedRecordPicklist = false;
    connectedCallback(){
        this.getRecordOptions();
    }

    getRecordOptions() {
        getRecordTypes()
            .then(data => {
                console.log(data)
                this.recordOptions = data;
            })
            .catch(error => {
                console.log('Error');
            })
        }
    handleChange(evt){
        this.recordTypeId = evt.detail.value;
    }
    handleSuccess(){
        this.desactivedRecordPicklist = true;
    }
}