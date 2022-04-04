import updateSubTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateSubTodoStatus';
import updateTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateTodoStatus';
import { LightningElement, api} from 'lwc';
import Id from '@salesforce/user/Id';


export default class SingleCard extends LightningElement {
    subtodoId;
    todoId;
    userId = Id;
    @api todo;
    todoStatus;
    subtodoStatus;
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
        
        console.log(this.todoStatus);
    }
    

   

    
   
}