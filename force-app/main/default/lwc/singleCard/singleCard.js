import updateSubTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateSubTodoStatus';
import updateTodoStatus from '@salesforce/apex/GetTodoSubTodo.updateTodoStatus';
import { LightningElement, api, track} from 'lwc';





export default class SingleCard extends LightningElement {
    subtodoId;
    todoId;
    checkboxVal=false;
    @api todo;
   
 
    checkboxVal1 = false;
    checkboxVal2 = false;
   
   

    
     updateSub(event) {
      
       this.subtodoId = event.currentTarget.dataset.id;
       console.log(this.subtodoId);
        updateSubTodoStatus( {recId: this.subtodoId })
      this.checkboxVal = true ;
      console.log(this.checkboxVal);
    }             
         

    updateHandler(event){
        
        this.todoId = event.currentTarget.dataset.id;
        console.log(this.todoId);
        updateTodoStatus( {recId: this.todoId })
        checkboxVal2 = true;
          }
    
    
   

    
   
}