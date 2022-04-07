import { LightningElement, track, wire, api } from 'lwc';
import getTodo from '@salesforce/apex/GetTodoSubTodo.getTodo';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/Record_Selected__c';

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

 @wire(MessageContext)
    messageContext;
	
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

    handleShowModal(event){
        const payload = { recordId: event.target.todo.Id };
        publish(this.messageContext, RECORD_SELECTED_CHANNEL, payload);
        
    }

    cancelModalHandler(event){
        const modal = this.template.querySelector('c-confirm-deleting-modal-window');
        modal.hide();
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