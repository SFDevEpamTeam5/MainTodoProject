import { LightningElement, track, wire, api } from 'lwc';
import getTodo from '@salesforce/apex/GetTodoSubTodo.getTodo';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


import templateProgress from './templateProgress.html';
import templateDone from './templateDone.html';
import getTodoDone from '@salesforce/apex/GetTodoSubTodo.getTodoDone';

export default class MyCardHolder extends LightningElement {

@track todos;
@track error;
@track todosdn;
@api stodo;
@api recordId;



todoId;
 @track wiredTodoResult;
 wiredTodoDoneResult
 showTemplateProgress = true;


	
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

    @wire(getTodoDone)
    wiredGetTodoDone( result) {
        this.wiredTodoResult = result;
        if (result.data) {
            this.todosdn = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.todosdn = undefined;
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

    

   
  /*     updateTodoHandler(event) {
        if (event) {
            refreshApex(this.wiredTodoResult);
        }
      }*/


      render() {
        return this.showTemplateProgress ? templateProgress : templateDone;
    }

    switchTemplate() {
        this.showTemplateProgress = !this.showTemplateProgress;
        refreshApex(this.wiredTodoResult);
        
    }
    

}