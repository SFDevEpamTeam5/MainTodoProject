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
 wiredTodoResult;
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

    

    

   editModalHandler(event){
        const modal = this.template.querySelector('c-add-edit-window');
        modal.show();
    }


 /*   deleteModalHandler(event){
    
        deleteRecord( {recId: this.recordId })
            .then(() => {
                return refreshApex(this.wiredTodoResult);
                    })
            .catch(error => {
                console.error("Error on deleting records ", error);
              });
    }*/
      


       updateTodoHandler(event) {
        if (event) {
            refreshApex(this.wiredTodoResult);
        }
      }


      render() {
        return this.showTemplateProgress ? templateProgress : templateDone;
    }

    switchTemplate() {
        this.showTemplateProgress = !this.showTemplateProgress;
    
        
    }
    

}