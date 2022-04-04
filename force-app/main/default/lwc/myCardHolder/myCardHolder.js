import { LightningElement, track, wire } from 'lwc';
import getTodo from '@salesforce/apex/GetTodoSubTodo.getTodo';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import getQueue from '@salesforce/apex/GetTodoSubTodo.getQueue';

export default class MyCardHolder extends LightningElement {

@track todos;
@track error;

userId = Id;
todoId;
wiredTodoResult;

	
	@wire(getTodo)
    wiredGetTodo( result) {
        this.wiredTodoResult = result;
        if (result.data) {
            this.todos = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.todos = undefined;
        }
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
                return refreshApex(this.wiredTodoResult);
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
       
    assignHandler(event){
        this.todoId = event.currentTarget.dataset.id;
        console.log(this.todoId);
        updateTodoStatus( {recId: this.todoId })
        return refreshApex(this.wiredTodoResult);
    }
  
    


}