public with sharing class GetTodoSubTodo {
    
    @AuraEnabled(cacheable=true)
    public static List<ToDo__c> getTodo(){
       
        return[SELECT Name, Status__c, OwnerId, (SELECT Id, Name FROM SubToDos__r) 
        FROM ToDo__c  WHERE Status__c = 'In progress'];
    
    }

    @AuraEnabled(cacheable=true)
    public static List<ToDo__c> getTodoDone(){
      
        return[SELECT Name, Status__c, OwnerId, (SELECT Id, Name FROM SubToDos__r) 
        FROM ToDo__c  WHERE Status__c = 'Done'];
    
    }



    @AuraEnabled(cacheable=true)
    public static List<ToDo__c> getQueue(){
      
        return[SELECT Name, Status__c, (SELECT Id, Name FROM SubToDos__r) 
        FROM ToDo__c  WHERE Status__c ='Ready to take'];
    
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
       ToDo__c td=[Select Id, Status__c, OwnerId FROM ToDo__c WHERE Id=: recId];
          if(td.Status__c == 'Ready to take'){
           td.Status__c ='In progress';
           td.OwnerId = UserInfo.getUserId();
            } else{
                td.IsDone__c = true;
                td.Status__c = 'Done';
                td.Completion_Date__c = Date.Today(); }
       
    
       try{
           update td;
       }
	   catch (Exception e) {
           System.debug('unable to update the record due to'+e.getMessage());
       }
     return true;
   }

   @AuraEnabled(cacheable=true)
   public static List<ToDo__c> search(String searchKey) {
       String key = '%' + searchKey + '%';
       String userId = UserInfo.getUserId();
       List<SubToDo__c> sbtd = [SELECT ToDo__c, Name, ToDo__r.OwnerId FROM SubToDo__c
        WHERE Name LIKE :key AND ToDo__r.OwnerId =: userId];
        List<ToDo__c> tdList = New List<ToDo__c>();
       for(SubToDo__c sb : sbtd){
          ToDo__c td = New ToDo__c();
           td.Id = sb.ToDo__c;
            tdList.add(td);
        }
                
       return [SELECT Id, Name, Status__c, OwnerId, (SELECT Name FROM SubToDos__r) 
       FROM ToDo__c Where (Name LIKE :key AND OwnerId =: userId) OR Id IN : tdList];                 
   }



}