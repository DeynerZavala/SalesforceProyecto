import {LightningElement, track } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCaseByContact';
import getStatusPicklistValues from '@salesforce/apex/CaseController.getStatusPicklistValues'
import getPriorityPicklistValues from '@salesforce/apex/CaseController.getPriorityPicklistValues'
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CREATED_DATE_FIELD from '@salesforce/schema/Case.CreatedDate';
import CLOSED_DATE_FIELD from '@salesforce/schema/Case.ClosedDate';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import SLA_STATUS_FIELD from '@salesforce/schema/Case.SLA_Status__c';

const COLUMNS = [
    { label: "Asunto", fieldName: SUBJECT_FIELD.fieldApiName},
    { label: "Priority ", fieldName: PRIORITY_FIELD.fieldApiName, sortable: true},
    { label: "Estado", fieldName: STATUS_FIELD.fieldApiName, sortable: true},
    { label: "Tipo", fieldName: 'recordTypeName', sortable: true},
    { label: "SLA Status", fieldName: SLA_STATUS_FIELD.fieldApiName, sortable: true},
    { label: "Fecha de Creación", fieldName: CREATED_DATE_FIELD.fieldApiName, sortable: true },
    { label: "Fecha de Cierre", fieldName: CLOSED_DATE_FIELD.fieldApiName, sortable: true }
];


const ROW_SIZE_MAX = 20;

export default class CaseOpenList extends LightningElement {
    openedCase = true;
}
