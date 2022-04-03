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
        Set<Id> queueCategoryIds = new Set<Id>();
        queueCategoryIds.addAll(todoQueues.values());
        for (ToDo__c t : newTodoMap.values()) {
            /*if (!queueCategoryIds.Contains(oldTodoMap.get(t.Id).OwnerId) && (!queueCategoryIds.Contains(newTodoMap.get(t.Id).OwnerId))) {
                if (t.Status__c != 'In progress' && t.Count_of_open_SubTodo__c != 0 &&
                (oldTodoMap.get(t.Id).Count_of_subTodo__c != newTodoMap.get(t.Id).Count_of_subTodo__c || oldTodoMap.get(t.Id).Count_of_open_SubTodo__c != newTodoMap.get(t.Id).Count_of_open_SubTodo__c)) {
                    t.Status__c = 'In progress';
                    t.Completion_Date__c = null;
                    t.IsDone__c = false;
                }
                if (t.Status__c != 'Done' && t.Count_of_open_SubTodo__c == 0 && t.Count_of_subTodo__c >= 0 && (oldTodoMap.get(t.Id).Count_of_subTodo__c != newTodoMap.get(t.Id).Count_of_subTodo__c || oldTodoMap.get(t.Id).Count_of_open_SubTodo__c != newTodoMap.get(t.Id).Count_of_open_SubTodo__c)) {
                    t.Status__c = 'Done';
                    t.IsDone__c = true;
                    if (t.Completion_Date__c == null) {
                        t.Completion_Date__c = Date.today();
                    }
                } 
            } else if (queueCategoryIds.Contains(oldTodoMap.get(t.Id).OwnerId) && !queueCategoryIds.Contains(newTodoMap.get(t.Id).OwnerId)) {
                t.Status__c = 'In progress';
                t.Completion_Date__c = null;
                t.IsDone__c = false;
            }*/
            if (t.Status__c != 'In progress' && t.Count_of_open_SubTodo__c != 0 &&
                (oldTodoMap.get(t.Id).Count_of_subTodo__c != newTodoMap.get(t.Id).Count_of_subTodo__c || oldTodoMap.get(t.Id).Count_of_open_SubTodo__c != newTodoMap.get(t.Id).Count_of_open_SubTodo__c)) {
                    t.Status__c = 'In progress';
                    t.Completion_Date__c = null;
            }
            if (t.Status__c != 'Done' && t.Count_of_open_SubTodo__c == 0 && t.Count_of_subTodo__c >= 0 && (oldTodoMap.get(t.Id).Count_of_subTodo__c != newTodoMap.get(t.Id).Count_of_subTodo__c || oldTodoMap.get(t.Id).Count_of_open_SubTodo__c != newTodoMap.get(t.Id).Count_of_open_SubTodo__c)) {
                    t.Status__c = 'Done';
                    if (t.Completion_Date__c == null) {
                        t.Completion_Date__c = Date.today();
                    }
            } 
            if (t.Deadline__c == null) {
                t.Deadline__c.AddError('Incorrect Date');
            }
            if ((t.Status__c != 'Done' && t.Completion_Date__c != null) ||
            (t.Status__c == 'Done' && t.Completion_Date__c == null)) {
                t.Completion_Date__c.AddError('Completion Date is incorrect');
            }
            if (t.Status__c == 'Done' && !t.IsDone__c) {
                t.IsDone__c = true;
            }else if (t.Status__c != 'Done' && t.IsDone__c){
                t.IsDone__c = false;
            }
            String category = ToDoUtility.getCategory(t.Deadline__c, t.Completion_Date__c);
            t.RecordTypeId = todoRecordtypes.get(category);
            if (queueCategoryIds.Contains(t.OwnerId)) {
                t.OwnerId = todoQueues.get(category);
            }
        }
    }
    //upload records to remote org
    public static void onAfterInsert(Map<Id,ToDo__c> newTodoMap) {
        Set<Id> todoIds = new Set<Id>();
        for (Id key : newTodoMap.keySet()) {
            if (!newTodoMap.get(key).Insert_from_remote_org__c) {
                todoIds.add(key);
            }
        }
        uploadTodoToRemoteOrg(todoIds);
    }
    //delete from remote org
    public static void onAfterDelete(Map<Id,ToDo__c> oldTodoMap) {
        Map<Id,ToDo__c> todosForDelete = new Map<Id,ToDo__c>(getTodoList(oldTodoMap.keySet()));
        if (!todosForDelete.isEmpty()) {
            List<Id> todoIds = new List<Id>();
            for (ToDo__c t : todosForDelete.values()) {
                todoIds.add(t.Id_Todo_from_another_org__c);
            }
            removeTodoFromRemoteOrg(todoIds);
        }  
    }
    //update records on another org
    public static void onAfterUpdate(Map<Id,ToDo__c> oldTodoMap, Map<Id,ToDo__c> newTodoMap) {
        Map<String, Schema.SObjectField> fieldmap = new Map<String,Schema.SObjectField>();
        Set<String> fieldExcludeList = new Set<String>{'LastModifiedDate', 'LastActivityDate', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate', 'OwnerId', 'RecordTypeId', 'Count_of_subTodo__c', 'Count_of_open_SubTodo__c'};
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.ToDo__c.fields.getMap();

        for(Schema.SObjectField F : Schema.SObjectType.ToDo__c.fields.getMap().values()) {
            if (!fieldExcludeList.contains(F.getDescribe().getName())) {
                fieldmap.put(f.getDescribe().getName(), F);
            }
        }

        Set<Id> todosForUpdateIds = new Set<Id>();
        for(ToDo__c t: newTodoMap.values() ){
            for(String fieldApiName : fieldmap.keySet()){
                if(t.get(fieldApiName) != oldTodoMap.get(t.Id).get(fieldApiName) ){
                    System.debug('field '+fieldApiName);
                    todosForUpdateIds.add(t.Id);
                }
            }
            if (newTodoMap.get(t.Id).Status__c != oldTodoMap.get(t.Id).Status__c &&
                newTodoMap.get(t.Id).IsDone__c != oldTodoMap.get(t.Id).IsDone__c&&
                newTodoMap.get(t.Id).Completion_Date__c != oldTodoMap.get(t.Id).Completion_Date__c &&
                (newTodoMap.get(t.Id).Count_of_SubTodo__c != oldTodoMap.get(t.Id).Count_of_SubTodo__c ||
                newTodoMap.get(t.Id).Count_of_open_SubTodo__c != oldTodoMap.get(t.Id).Count_of_open_SubTodo__c)){
                    todosForUpdateIds.remove(t.Id);
                }
        }
        
        System.debug('call from update after '+todosForUpdateIds.size());
        if (!todosForUpdateIds.isEmpty()) {
            if (!System.isFuture()) {
                updateTodoFromRemoteOrg(todosForUpdateIds);
            }
        }
    }
    @future(callout=true)
    public static void uploadTodoToRemoteOrg (Set<Id> todoids) {
        List<ToDo__c> todoList = getTodolist(todoids);
        List<ToDo__c> uploadedTodos = CallTodoRestService.callPost(todoList);
        update uploadedTodos;
    }
    @future(callout=true)
    public static void removeTodoFromRemoteOrg (List<Id> todoIds) {
        CallTodoRestService.callDelete(todoIds);
    }
    @future(callout=true)
    public static void updateTodoFromRemoteOrg(Set<Id> todoIds) {
        List<ToDo__c> todoList = getTodoList(todoIds);
        CallTodoRestService.callPatch(todoList);
    }
    private static List<ToDo__c> getTodoList(Set<Id> todoIds) {
        return [
            SELECT Id, Name, Deadline__c, Completion_Date__c, Status__c, Category__c, IsDone__c, Count_of_SubTodo__c, Count_of_open_SubTodo__c, Id_Todo_from_another_org__c
            FROM ToDo__c
            WHERE Id IN :todoids
        ];
    }
}