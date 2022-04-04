public with sharing class GetTodoSubTodo {
    
    @AuraEnabled(cacheable=true)
    public static List<ToDo__c> getTodo(){
       String userId =UserInfo.getUserId();
        return[SELECT Name, Status__c, OwnerId, (SELECT Id, Name FROM SubToDos__r) 
        FROM ToDo__c  WHERE OwnerId =: userId AND Status__c = 'In progress'];
    
    }

    @AuraEnabled(cacheable=true)
    public static List<ToDo__c> getQueue(){
       String userId =UserInfo.getUserId();
        return[SELECT Name, Status__c, OwnerId, (SELECT Id, Name FROM SubToDos__r) 
        FROM ToDo__c  WHERE OwnerId !=: userId WITH SECURITY_ENFORCED];
    
    }
    @AuraEnabled
   public static Boolean updateSubTodoStatus(String recId){
       SubToDo__c sub=[Select Id, IsDone__c from SubToDo__c WHERE Id=: recId];
       sub.IsDone__c = true;
       try{
           update sub;
           
       }
	   catch (Exception e) {
           System.debug('unable to update the record due to'+e.getMessage());
       }
       return true;
   }

   @AuraEnabled
   public static Boolean updateTodoStatus(String recId){
       ToDo__c td=[Select Id, Status__c, OwnerId from ToDo__c WHERE Id=: recId];
           if(td.Status__c == 'Ready to take'){
           td.Status__c ='In progress';
           td.OwnerId = UserInfo.getUserId();
       }
       else{ td.Status__c = 'Done';}
       try{
           update td;
       }
	   catch (Exception e) {
           System.debug('unable to update the record due to'+e.getMessage());
       }
      return true;
   }
}

