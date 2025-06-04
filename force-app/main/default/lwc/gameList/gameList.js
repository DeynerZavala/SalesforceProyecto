import {api,LightningElement, track } from 'lwc';
import getGames from '@salesforce/apex/GameController.getGames';
import getGenrePicklistValues from '@salesforce/apex/GameController.getGenrePicklistValues'
import getPlatformPicklistValues from '@salesforce/apex/GameController.getPlatformPicklistValues'
import RELEASE_DATE_FIELD from '@salesforce/schema/Game__c.Release_Date__c';
import PLATFORM_FIELD from '@salesforce/schema/Game__c.Platform__c';
import AGE_RATING_FIELD from '@salesforce/schema/Game__c.Age_Rating__c';
import GENRE_FIELD from '@salesforce/schema/Game__c.Genre__c';
import NAME_FIELD from '@salesforce/schema/Game__c.Name';

const COLUMNS = [
    { label: "Nombre", fieldName: NAME_FIELD.fieldApiName},
    { label: "Género", fieldName: GENRE_FIELD.fieldApiName},
    { label: "Fecha de Lanzamiento", fieldName: RELEASE_DATE_FIELD.fieldApiName, sortable: true },
    { label: "Plataforma", fieldName: PLATFORM_FIELD.fieldApiName },
    { label: "Clasificación por edad", fieldName: AGE_RATING_FIELD.fieldApiName, sortable: true}
];


const ROW_SIZE_MAX = 20;

export default class GameList extends LightningElement {
    @track games = [];
    @track currentPage = 1;
    isFilterActive = false;

    columns = COLUMNS;
    searchText = '';
    platform = '';
    genre = '';
    sortDirection;
    sortedBy;
    disabledPrev = true;
    disabledNext = false;
    @track genrePicklistValue = [];
    @track platformPicklistValue= [];
    selectedPlatform;
    selectedGenre;

    connectedCallback() {
        this.loadGames();
        this.loadValuesPicklist();
    }

    
    loadValuesPicklist(){
        getGenrePicklistValues()
        .then(data => {
            this.genrePicklistValue = data;
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
        getPlatformPicklistValues()
        .then(data => {
            this.platformPicklistValue = data;
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
    }
    loadGames() {
        getGames({
            searchText: this.searchText,
            platform: this.platform,
            genre: this.genre,
            sortedBy: this.sortedBy,
            offset: this.offset,
            limitRow: ROW_SIZE_MAX,
            sortDirection: this.sortDirection
        })
        .then(data => {
            console.log("Data:", data);
            this.games = data;
            this.disabledPrev = this.currentPage === 1;
            this.disabledNext = data.length < ROW_SIZE_MAX;
        })
        .catch(error => {
            this.error = error;
            this.games = [];
            this.disabledPrev = true;
            this.disabledNext = true;
            console.error("Error en loadGames:", error);
        });
    }
    get offset() {
        return (this.currentPage - 1) * ROW_SIZE_MAX;
    }
    handleSearch(evt) {
        this.searchText = evt.target.value;
        this.currentPage = 1;
        if (this.searchText.length === 0 || this.searchText.length > 2) {
            this.loadGames();
        }
    }
    handlePrev() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadGames();
        }
    }
    handleNext() {
        if (!this.disabledNext) {
            this.currentPage++;
            this.loadGames();
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
        this.loadGames();
    }
    toggleFilters(){
        this.isFilterActive = !this.isFilterActive;
    }
    get tableClass() {
        return this.isFilterActive ? 'table-with-filter' : 'table-full';
    }
    handlePlatform(evt){
        this.platform = evt.target.value;
        this.currentPage = 1;
        this.loadGames();
    }
    handleGenre(evt){
        this.genre = evt.target.value;
        this.currentPage = 1;
        this.loadGames();
    }
}
