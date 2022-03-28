public with sharing class ToDoTriggerHandler {
    public static void onBeforeInsert(List<ToDo__c> todoList) {
        recordsProcessing(todoList, false);
    }
    public static void onBeforeUpdate(Map<Id,ToDo__c> oldmap,Map<Id,ToDo__c> newmap) {
        recordsProcessing(newmap.values(), true);
    }
    private static void recordsProcessing(List<ToDo__c> todoList,Boolean isUpdate) {
        for (ToDo__c t : todoList) {
            if (isUpdate) {
                if (t.Status__c != 'In progress' && t.Count_of_open_SubTodo__c != 0 && t.Count_of_open_SubTodo__c < t.Count_of_subTodo__c) {
                    t.Status__c = 'In progress';
                    t.Completion_Date__c = null;
                    t.IsDone__c = false;
                }
                if (t.Status__c != 'Ready to take' && t.Count_of_SubTodo__c > 0 && t.Count_of_open_SubTodo__c == t.Count_of_SubTodo__c) {
                    t.Status__c = 'Ready to take';
                    t.Completion_Date__c = null;
                    t.IsDone__c = false;
                }
                if (t.Status__c != 'Done' && t.Count_of_open_SubTodo__c == 0 && t.Count_of_subTodo__c > 0) {
                    t.Status__c = 'Done';
                    t.IsDone__c = true;
                    if (t.Completion_Date__c == null) {
                        t.Completion_Date__c = Date.today();
                    }
                }
            }
            if (t.Deadline__c == null) {
                t.Deadline__c.AddError('Incorrect Date');
            }
            if ((t.Status__c != 'Done' && t.Completion_Date__c != null) ||
            (t.Status__c == 'Done' && t.Completion_Date__c == null)) {
                t.Completion_Date__c.AddError('Completion Date is incorrect');
            }
            String category = getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = getToDoRecordTypes().get(category);
            if (!isUpdate) {
                t.OwnerId = getQueues().get(category);
            }
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
}