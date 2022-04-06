import search from '@salesforce/apex/GetTodoSubTodo.search';
import { LightningElement, wire } from 'lwc';


export default class MainScreen extends LightningElement {
    searchKey = '';
    stodo;
    error;

  
    handleKeyChange(event) {
        this.searchKey = event.target.value;
        console.log(this.searchKey);
    }


    handleKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        search({ searchKey: this.searchKey })
            .then((result) => {
                this.stodo = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.stodo = undefined;
            });
    }

}