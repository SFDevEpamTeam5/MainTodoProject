public with sharing class SubToDoController {
    @AuraEnabled
    public static List<SubToDo__c> getSubTodoList(String recordid) {
        return [
            SELECT Id, Name, IsDone__c, SubToDo__c.ToDo__c
            FROM SubToDo__c
            WHERE SubToDo__c.ToDo__c = :recordid
        ];
    }
    @AuraEnabled
    public static String createSubTodo (String todorecordid,String title){
        System.debug(todorecordid+'  '+title);
        SubToDo__c s = new SubToDo__c(Name=title);
        s.ToDo__c = todorecordid;
        insert s;
        return s.Id;
    }
    @AuraEnabled
    public static void updateSubtodo(String subtodos){
        List<SubtTodoEntity> subtodoFromFront = (List<SubtTodoEntity>)JSON.deserialize(subtodos, List<SubtTodoEntity>.class);
        List<SubToDo__c> subtodoForUpdate = new List<SubToDo__c>();
        for (SubtTodoEntity s : subtodoFromFront) {
            SubToDo__c subt = new SubToDo__c();
            subt.Id = (Id) s.subid;
            subt.IsDone__c = (Boolean)s.isdone;
            subt.ToDo__c = (Id)s.parentid;
            subtodoForUpdate.add(subt);
        }
        update subtodoForUpdate;
    }
    @AuraEnabled
    public static void deleteSubtodo(String subtodoid){
        SubToDo__c subt = [
            SELECT Id
            FROM SubToDo__c
            WHERE Id = :subtodoid LIMIT 1
        ];
        if (subt != null) {
            delete subt;
        }
    }
    public class SubtTodoEntity {
        String subid;
        Boolean isdone;
        String parentid;
    }
}
