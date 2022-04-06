import updateSubTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateSubTodoStatus';
import updateTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateTodoStatus';
import { LightningElement, api, } from 'lwc';





export default class SingleCard extends LightningElement {
    subtodoId;
    todoId;

    @api todo;
   
 
    checkboxVal = false;
   
   

    
     updateSub(event) {
      
       this.subtodoId = event.currentTarget.dataset.id;
       console.log(this.subtodoId);
      updateSubTodoStatus( {recId: this.subtodoId })
       
    }             
         

    updateHandler(event){
        
        this.todoId = event.currentTarget.dataset.id;
        console.log(this.todoId);
        updateTodoStatus( {recId: this.todoId })
        .then(result => {
          //on successful update, fire an event to notify parent component
          const updateEvent = new CustomEvent("update", { detail: this.todoId });
          this.dispatchEvent(updateEvent);
          
        })
        .catch(error => {
          console.error("Error in updatig records ", error);
        });

       
    }
    
    
   

    
   
}