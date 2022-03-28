import { LightningElement, track } from 'lwc';
import getTodosForCategory from '@salesforce/apex/ToDoController.getTodolistForCategory';

export default class TodoList extends LightningElement {
    @track list;
    @track error;
    connectedCallback() {
        getTodosForCategory().then(result => {
            this.list = result;
        }).catch(error => {
            this.error = error
        });
    }
}