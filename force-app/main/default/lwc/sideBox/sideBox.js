import getQueue from '@salesforce/apex/GetTodoSubTodo.getQueue';
import updateTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateTodoStatus';
import { LightningElement,track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';


export default class SideBox extends LightningElement {

@track tasks;
@track error;

wiredResult;
taskId;

@wire(getQueue)
    wiredGetQueue(result) {
        this.wiredResult = result;
        if (result.data) {
            this.tasks = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.tasks = undefined;
        }
    }


    assingHandler(event){
    this.taskId = event.currentTarget.dataset.id;
    console.log(this.taskId);
    updateTodoStatus( {recId: this.taskId })
    .then(result => {
      
        return refreshApex(this.wiredResult);
    })
    .catch(error => {
      console.error("Error in updatig records ", error);
    });

    }
}