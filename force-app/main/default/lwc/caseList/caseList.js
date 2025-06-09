import {LightningElement, track,api } from 'lwc';
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

export default class CaseList extends LightningElement {
    @track cases = [];
    @track currentPage = 1;
    isFilterActive = false;
    @api
    openedCase=false; 
    columns = COLUMNS;
    searchText = '';
    priority = '';
    status = '';
    sortDirection;
    sortedBy;
    disabledPrev = true;
    disabledNext = false;
    @track statusPicklistValue = [];
    @track priorityPicklistValue= [];
    selectedPriority;
    selectedStatus;

    connectedCallback() {
        this.loadCases();
        this.loadValuesPicklist();
    }

    loadValuesPicklist(){
        getStatusPicklistValues()
        .then(data => {
            this.statusPicklistValue = [{ label: 'Todos', value: '' }, ...data];
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
        getPriorityPicklistValues()
        .then(data => {
            this.priorityPicklistValue = [{ label: 'Todos', value: '' }, ...data];
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
    }
    loadCases() {
        getCases({
            searchText: this.searchText,
            priority: this.priority,
            status: this.status,
            sortedBy: this.sortedBy,
            offset: this.offset,
            limitRow: ROW_SIZE_MAX,
            sortDirection: this.sortDirection,
            openedCase: this.openedCase
        })
        .then(data => {
            console.log("opened:", this.openedCase);
            console.log("Data:", data);
            this.cases = data.map(item => ({
                ...item,
                recordTypeName: item.RecordType?.Name || ''
            }));
            this.disabledPrev = this.currentPage === 1;
            this.disabledNext = data.length < ROW_SIZE_MAX;
        })
        .catch(error => {
            this.error = error;
            this.cases = [];
            this.disabledPrev = true;
            this.disabledNext = true;
            console.error("Error en loadCases:", error);
        });
    }
    get offset() {
        return (this.currentPage - 1) * ROW_SIZE_MAX;
    }
    handleSearch(evt) {
        this.searchText = evt.target.value;
        this.currentPage = 1;
        if (this.searchText.length === 0 || this.searchText.length > 2) {
            this.loadCases();
        }
    }
    handlePrev() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadCases();
        }
    }
    handleNext() {
        if (!this.disabledNext) {
            this.currentPage++;
            this.loadCases();
        }
    }
    handleSort(evt){
        const { fieldName, sortDirection } = evt.detail;

        if (this.sortedBy === fieldName) {
        this.sortDirection = (this.sortDirection === 'asc') ? 'desc' : 'asc';
        } else {
            this.sortedBy = fieldName;
            this.sortDirection = 'asc';
        }
        this.currentPage = 1;
        this.loadCases();
    }
    toggleFilters(){
        this.isFilterActive = !this.isFilterActive;
        if(!this.isFilterActive){

        }
    }
    get tableClass() {
        return this.isFilterActive ? 'table-with-filter' : 'table-full';
    }
    handlePriority(evt){
        this.priority = evt.target.value;
        this.currentPage = 1;
        this.loadCases();
    }
    handleStatus(evt){
        this.status = evt.target.value;
        this.currentPage = 1;
        this.loadCases();
    }
    handleOpenedCase(event) {
        this.openedCase = event.target.checked;
        this.loadCases();
    }
}
