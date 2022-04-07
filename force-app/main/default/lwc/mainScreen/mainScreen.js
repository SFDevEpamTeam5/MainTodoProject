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

    deleteHandler(event) {
        const recordId = event.currentTarget.dataset.id;
        
        deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'ToDo Task deleted',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
        }


}