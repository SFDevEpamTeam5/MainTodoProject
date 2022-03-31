public with sharing class CreateTodoFromCase {

    public static void createTodo(List<Case> cs) {
        List<ToDo__c> newtd = New List<ToDo__c>();
        for(Case c : cs)
        {
            ToDo__c td = New ToDo__c(Name = c.Subject, Status__c = 'Ready to take');
            newtd.add(td);    
        }
        insert newtd;
    }
}
