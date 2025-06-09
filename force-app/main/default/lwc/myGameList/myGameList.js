import {LightningElement, track } from 'lwc';
import getMyGames from '@salesforce/apex/GameController.getUserGameRelations';
import getGenrePicklistValues from '@salesforce/apex/GameController.getGenrePicklistValues'
import getPlatformPicklistValues from '@salesforce/apex/GameController.getPlatformPicklistValues'


const COLUMNS = [
    { label: "Nombre", fieldName: "gameName"},
    { label: "Género", fieldName: "genre"},
    { label: "Fecha de Lanzamiento", fieldName: "releaseDate", sortable: true },
    { label: "Plataforma", fieldName: "platform" },
    { label: "Clasificación por edad", fieldName: "ageRating", sortable: true},
    { label: "Ranking", fieldName: "ranking", sortable: true}
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
            this.genrePicklistValue = [{ label: 'Todos', value: '' }, ...data];
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
        getPlatformPicklistValues()
        .then(data => {
            this.platformPicklistValue = [{ label: 'Todos', value: '' }, ...data];
        }
        )
        .catch(error => {
            console.log("Error en loadValuesPicklist:", error);
        });
    }
    loadGames() {
        getMyGames({
            searchText: this.searchText,
            platform: this.platform,
            genre: this.genre,
            sortedBy: this.sortedBy,
            offset: this.offset,
            limitRow: ROW_SIZE_MAX,
            sortDirection: this.sortDirection
        })
        .then(data => {
            console.log("Data My Games:", data);
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
        if(!this.isFilterActive){

        }
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
