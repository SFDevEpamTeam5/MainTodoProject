public with sharing class ToDoTriggerHandler {
    public static void onBeforeInsert(List<ToDo__c> todoList) {
        Map<String,Id> todoRecordtypes = ToDoUtility.getToDoRecordTypes();
        Map<String,Id> todoQueues = ToDoUtility.getQueues();
        for (ToDo__c t : todoList) {
            if (t.Status__c != 'Ready to take') {
                t.Status__c.AddError('Status must be \'Ready to take\'');
            }
            if (t.Deadline__c == null) {
                t.Deadline__c.AddError('Incorrect Date');
            }
            if (t.Completion_Date__c != null) {
                t.Completion_Date__c.AddError('Field must be empty');
            }
            String category = ToDoUtility.getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = todoRecordtypes.get(category);
            t.OwnerId = todoQueues.get(category);
        }
    }
    public static void onBeforeUpdate(Map<Id,ToDo__c> oldTodoMap,Map<Id,ToDo__c> newTodoMap) {
        Map<String,Id> todoRecordtypes = ToDoUtility.getToDoRecordTypes();
        Map<String,Id> todoQueues = ToDoUtility.getQueues();
        Set<Id> recordtypesIds = ToDoUtility.getTodoRecordTypesIds(todoQueues);
        for (ToDo__c t : newTodoMap.values()) {
            if (!recordtypesIds.Contains(oldTodoMap.get(t.Id).OwnerId) && (!recordtypesIds.Contains(newTodoMap.get(t.Id).OwnerId))) {
                if (t.Status__c != 'In progress' && t.Count_of_open_SubTodo__c != 0) {
                    t.Status__c = 'In progress';
                    t.Completion_Date__c = null;
                    t.IsDone__c = false;
                }
                if (t.Status__c != 'Done' && t.Count_of_open_SubTodo__c == 0 && t.Count_of_subTodo__c >= 0) {
                    t.Status__c = 'Done';
                    t.IsDone__c = true;
                    if (t.Completion_Date__c == null) {
                        t.Completion_Date__c = Date.today();
                    }
                } 
            } else if (recordtypesIds.Contains(oldTodoMap.get(t.Id).OwnerId) && !recordtypesIds.Contains(newTodoMap.get(t.Id).OwnerId)) {
                t.Status__c = 'In progress';
                t.Completion_Date__c = null;
                t.IsDone__c = false;
            }
            if (t.Deadline__c == null) {
                t.Deadline__c.AddError('Incorrect Date');
            }
            if ((t.Status__c != 'Done' && t.Completion_Date__c != null) ||
            (t.Status__c == 'Done' && t.Completion_Date__c == null)) {
                t.Completion_Date__c.AddError('Completion Date is incorrect');
            }
            String category = ToDoUtility.getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = todoRecordtypes.get(category);
            if (recordtypesIds.Contains(t.OwnerId)) {
                t.OwnerId = todoQueues.get(category);
            }
        }
    }
}