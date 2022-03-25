public with sharing class ToDoTriggerHandler {
    public static void onBeforeInsert(List<ToDo__c> todoList) {
        recordsProcessing(todoList, false);
    }
    public static void onBeforeUpdate(Map<Id,ToDo__c> oldTodoMap,Map<Id,ToDo__c> newTodoMap) {
        List<ToDo__c> TodosForProcess = new List<ToDo__c>();
        for (Id key : oldTodoMap.keySet()) {
            if (oldTodoMap.get(key).Deadline__c != newTodoMap.get(key).Deadline__c ||
            oldTodoMap.get(key).Count_of_subTodo__c != newTodoMap.get(key).Count_of_subTodo__c ||
            oldTodoMap.get(key).Count_of_open_SubTodo__c != newTodoMap.get(key).Count_of_open_SubTodo__c ||
            oldTodoMap.get(key).Completion_Date__c != newTodoMap.get(key).Completion_Date__c ||
            oldTodoMap.get(key).Status__c != newTodoMap.get(key).Status__c ||
            oldTodoMap.get(key).isDone__c != newTodoMap.get(key).isDone__c) {
                TodosForProcess.add(newTodoMap.get(key));
            }
            recordsProcessing(TodosForProcess, true);
        }
    }
    private static Map<String,String> getToDoRecordTypes() {
        Map<String,String> recordTypesMap = new Map<String,String>();
        for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE sObjectType = 'ToDo__c']) {
            recordTypesMap.put(rt.DeveloperName,rt.Id);
        }
        return recordTypesMap;
    }
    private static Map<String,String> getQueues() {
        Map<String,String> queuesMap = new Map<String,String>();
        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :getToDoRecordTypes().keySet()];
        for (Group gr : queues) {
            queuesMap.put(gr.Name,gr.Id);
        }
        return queuesMap;
    }
    private static void recordsProcessing(List<ToDo__c> todoList,Boolean isUpdate) {
        Map<String,String> reccordTypesMap = getToDoRecordTypes();
        Map<String,String> queuesMap = getQueues();
        for (ToDo__c t : todoList) {
            if (isUpdate) {
                if ((t.Status__c == 'Done' || t.Status__c == 'Ready to take') && t.Count_of_open_SubTodo__c != 0 && t.Count_of_subTodo__c > 0) {
                    t.Status__c = 'In progress';
                    t.Completion_Date__c = null;
                }
                if (t.Count_of_open_SubTodo__c == 0 && t.Count_of_subTodo__c > 0) {
                    t.Status__c = 'Done';
                }
            }
            String category = '';
            if (t.Status__c == 'Done') {
                if (t.Completion_Date__c == null) {
                    t.Completion_Date__c = Date.today();
                }
                category = getCategory(t.deadline__c, t.Completion_Date__c);
                t.IsDone__c = true;
            } else {
                if (t.Completion_Date__c != null) {
                    t.Completion_Date__c = null;
                }
                category = getCategory(t.deadline__c, Date.today());
                t.IsDone__c = false;
            }
            t.RecordTypeId = reccordTypesMap.get(category);
            t.OwnerId = queuesMap.get(category);
        }
    }
    private static String getCategory(Date deadline, Date targetDate) {
        if (deadline > targetDate +1) {
            return 'Later';
        }
        if (deadline == targetDate + 1) {
            return 'Tomorrow';
        }
        if (deadline == targetDate) {
            return 'Today';
        }
        if (deadline < targetDate) {
            return 'Overdue';
        }
        return null;
    }
    
}