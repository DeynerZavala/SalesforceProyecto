import { LightningElement, api} from 'lwc';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import getRecordTypes from '@salesforce/apex/CaseController.getCaseRecordTypes'
import CASE_OBJECT from '@salesforce/schema/Case';
import getContactIdForCurrentUser from '@salesforce/apex/ContactController.getContactIdForCurrentUser';

export default class CaseForm extends LightningElement {
    fields  = [SUBJECT_FIELD.fieldApiName,PRIORITY_FIELD.fieldApiName,DESCRIPTION_FIELD.fieldApiName];
    
    objectApiName =CASE_OBJECT.objectApiName;
    recordOptions;
    recordTypeId;
    desactivedRecordPicklist = false;
    contactId =null;
    connectedCallback(){
        this.getRecordOptions();
        this.getContactId();
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

    getContactId(){
        getContactIdForCurrentUser()
        .then(contactId => {
            this.contactId = contactId;
            console.log('ContactId obtenido:', contactId);
        })
        .catch(error => {
            console.error('Error al obtener ContactId:', error);
        });
    }
    handleChange(evt){
        this.recordTypeId = evt.detail.value;
    }
    handleSubmit(evt){
        const fields = evt.detail.fields;
        console.log(fields);
        fields.ContactId = this.contactId ? this.contactId : null;
        fields.Origin = 'Web Portal';
    }
    handleSuccess(){
        this.desactivedRecordPicklist = true;
        console.log('exito');
    }
    handleError(event) {
        const message = event?.detail?.message;
        console.log(message)
        console.log('error')
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}