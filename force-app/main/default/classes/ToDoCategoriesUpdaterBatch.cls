public class ToDoCategoriesUpdaterBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, Status__c, Deadline__c, '
        +'Completion_Date__c, IsDone__c, RecordTypeId, OwnerId FROM ToDo__c');
    }
    public void execute(Database.BatchableContext bc,List<SObject> scope) {
        Map<String,Id> todoRecordTypesMap = ToDoUtility.getToDoRecordTypes();
        Map<String,Id> todoQueues = ToDoUtility.getQueues();
        Set<Id> recordtypesIds = ToDoUtility.getTodoRecordTypesIds(todoRecordTypesMap);
        Set<ToDo__c> todoSetForUpdate = new Set<ToDo__c>();
        for (SObject s: scope) {
            ToDo__c t = (ToDo__c)s;
            if (t.Status__c != 'Done') {
                String category = ToDoUtility.getCategory(t.Deadline__c, Date.today());
                t.RecordTypeId = todoRecordTypesMap.get(category);
                todoSetForUpdate.add(t);
            }
            if (recordtypesIds.Contains(t.OwnerId)) {
                String category = ToDoUtility.getCategory(t.Deadline__c, Date.today());
                t.OwnerId = todoQueues.get(category);
                todoSetForUpdate.add(t);
            }
        }
        List<ToDo__c> todolist = new List<ToDo__c>();
        todolist.addAll(todoSetForUpdate);
        update todolist;
    }
    public void finish(Database.BatchableContext bc) {

    }
}
