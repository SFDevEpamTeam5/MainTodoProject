public with sharing class CreateTodoFromCase {

    public static void createTodo(List<Case> cs) {
        List<ToDo__c> newtd = New List<ToDo__c>();
        Date myDate = null;
        
        for(Case c : cs)
        {   
            try{
                myDate = Date.valueOf(c.Description);
            } catch (Exception e){
                myDate = Date.today();
            }  
            ToDo__c td = New ToDo__c(Name = c.Subject, Status__c = 'Ready to take', Deadline__c = myDate);
            newtd.add(td);    
        }
        insert newtd;
    }
}

//test 100%