public with sharing class ToDoTriggerHandler {
    public static void onBeforeInsert(List<ToDo__c> todoList) {
        Map<String,Id> todoRecordtypes = getToDoRecordTypes();
        Map<String,Id> todoQueues = getQueues();
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
            String category = getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = todoRecordtypes.get(category);
            t.OwnerId = todoQueues.get(category);
        }
    }
    public static void onBeforeUpdate(Map<Id,ToDo__c> oldTodoMap,Map<Id,ToDo__c> newTodoMap) {
        Map<String,Id> todoRecordtypes = getToDoRecordTypes();
        Map<String,Id> todoQueues = getQueues();
        Set<Id> recordtypesIds = getTodoRecordTypesIds(todoQueues);
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
            String category = getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = todoRecordtypes.get(category);
            if (recordtypesIds.Contains(t.OwnerId)) {
                t.OwnerId = todoQueues.get(category);
            }
        }
    }

    private static Map<String,Id> getToDoRecordTypes() {
        Map<String,Id> recordTypesMap = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE sObjectType = 'ToDo__c']) {
            recordTypesMap.put(rt.DeveloperName,rt.Id);
        }
        return recordTypesMap;
    }
    private static Map<String,Id> getQueues() {
        Map<String,Id> queuesMap = new Map<String,Id>();
        List<Group> queues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :getToDoRecordTypes().keySet()];
        for (Group gr : queues) {
            queuesMap.put(gr.Name,gr.Id);
        }
        return queuesMap;
    }
    private static String getCategory(Date deadline, Date completionDate) {
        if (completionDate == null) {
            completionDate = Date.today();
        }
        if (deadline > completionDate +1) {
            return 'Later';
        }
        if (deadline == completionDate + 1) {
            return 'Tomorrow';
        }
        if (deadline == completionDate) {
            return 'Today';
        }
        if (deadline < completionDate) {
            return 'Overdue';
        }
        return null;
    }
    private static Set<Id> getTodoRecordTypesIds(Map<String,Id> recordTypesMap) {
        Set<Id> recordTypeIds = new Set<Id>();
        for (String recordType : recordTypesMap.values()) {
            recordTypeIds.add(recordType);
        }
        return recordTypeIds;
    }
}