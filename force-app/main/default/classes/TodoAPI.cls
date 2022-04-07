@RestResource(urlMapping='/Todo/*')
global with sharing class TodoAPI {
	
    @HttpGet
    global static ToDo__c doGet() {
        RestRequest req = RestContext.request;
        String todoId = getId(req);
        List<ToDo__c> result = [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
                          IsDone__c, OwnerId, RecordTypeId, Status__c, 
                          Id_Todo_from_another_org__c FROM Todo__c WHERE Id = :todoId];
        if(result.size() > 0) return result[0];
        return null;
       
    }
    
    @HttpPost
    global static Map<String, String> doPost(){
        RestRequest req = RestContext.request;
        List<Todo__c> todoList = getListFromBody(req);
        List<Todo__c> forInsert = new List<Todo__c>();
        for(Todo__c t : todoList){
            Todo__c todoForInsert = createNewTodo(t);
            forInsert.add(todoForInsert);
        }                          
        if(todoList.size() > 0){
            Map<String, String> resMap = new Map<String, String>();
            Database.SaveResult[] srList = Database.insert(forInsert, false);
            for (Integer i = 0; i < todoList.size(); i++) {
    		Database.SaveResult s = srList[i];
    		Todo__c origRecord = todoList[i];
                if (s.isSuccess()){
                    resMap.put(origRecord.Id_Todo_from_another_org__c, s.getId());
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_Todo_from_another_org__c, errors);
     			}           
        	}
            return resMap;
     	}
    	return null;
    }
    
    @HttpDelete
    global static Map<String, String> doDelete() {
        Map<String, String> resMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        Blob jsonTodoString = req.requestBody;
        List<Id> idList = (List<Id>)JSON.deserialize(jsonTodoString.toString(), List<Id>.class);
        List<ToDo__c> listForDelete = [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
                          IsDone__c, OwnerId, RecordTypeId, Status__c, 
                          Id_Todo_from_another_org__c FROM Todo__c WHERE Id = :idList];
        
        if(listForDelete.size() > 0){
            List <Database.DeleteResult> srList = Database.delete(listForDelete, false);
            for (Integer i = 0; i < listForDelete.size(); i++) {
    		Database.DeleteResult s = srList[i];
    		Todo__c origRecord = listForDelete[i];
                if (s.isSuccess()){
                    resMap.put(origRecord.Id_Todo_from_another_org__c, 'deleted');
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_Todo_from_another_org__c, errors);
     			}           
        	}
            return resMap;
     	}
        return null;    
    }
    
        @HttpPatch
    global static Map<String, String> doPatch(){
        Map<String, String> resMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        List<Todo__c> todoList = getListFromBody(req);
        List<Todo__c> forUpdate = new List<Todo__c>();
        for(Todo__c t : todoList){
            Todo__c todoForUpdate = createNewTodo(t);
            forUpdate.add(todoForUpdate);
        }                          
        if(forUpdate.size() > 0){
            Database.SaveResult[] srList = Database.update(forUpdate, false);
            for (Integer i = 0; i < forUpdate.size(); i++) {
    		Database.SaveResult s = srList[i];
    		Todo__c origRecord = forUpdate[i];
                if (s.isSuccess()){
                    resMap.put(origRecord.Id_Todo_from_another_org__c, 'updating succses');
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_Todo_from_another_org__c, errors);
     			}           
        	}
            return resMap;
     	}
    	return null;
    }
    
    @HttpPut
    global static Map<String, String> doPut(){
        Map<String, String> resMap = new Map<String, String>();
        RestRequest req = RestContext.request;
        List<Todo__c> todoList = getListFromBody(req);
        List<Todo__c> forUpdate = new List<Todo__c>();
        for(Todo__c t : todoList){
            Todo__c todoForUpsert = createNewTodo(t);
            forUpdate.add(todoForUpsert);
        }                          
        if(forUpdate.size() > 0){
            System.debug('forUpdate ' + forUpdate);
            Database.UpsertResult[] srList = Database.upsert(forUpdate, false);
            for (Integer i = 0; i < forUpdate.size(); i++) {
    		Database.UpsertResult s = srList[i];
    		Todo__c origRecord = forUpdate[i];
                if (s.isSuccess()){
                    if(!s.isCreated()){
                        resMap.put(origRecord.Id_Todo_from_another_org__c, 'updating succses');
                    }
                    	resMap.put(origRecord.Id_Todo_from_another_org__c, 'record created :' + s.getId());     
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_Todo_from_another_org__c, errors);
     			}           
        	}
            return resMap;
     	}
    	return null;
    }

    @TestVisible
    private static Todo__c createNewTodo(Todo__c t){
        Id another = t.Id;
        String idFromAnotherOrg = t.Id_Todo_from_another_org__c;  
        if(String.isNotEmpty(t.Id_Todo_from_another_org__c)){
            t.Id = t.Id_Todo_from_another_org__c;
            System.debug('t.Id' + t.Id);   
        }
        t.Id_Todo_from_another_org__c = another;
        t.Insert_from_remote_org__c = true;
        Map<String, Object> toDotMap1 = new Map<String, Object>(t.getPopulatedFieldsAsMap());
		toDotMap1.remove( 'OwnerId' );
        if (String.isEmpty(idFromAnotherOrg)){
            toDotMap1.remove( 'Id' );
        }
		Todo__c newTodo = (Todo__c) JSON.deserialize( JSON.serialize( toDotMap1 ), Todo__c.class );
        return newTodo;
    }

    @TestVisible
    private static List<Todo__c> getListFromBody(RestRequest req){
        Blob jsonTodoString = req.requestBody;
        List<Todo__c> todoList = (List<Todo__c>)JSON.deserialize(jsonTodoString.toString(), List<Todo__c>.class);
        return todoList;
    }

    @TestVisible
    private static String getId(RestRequest req){
        String todoId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return todoId;
    }
}

//test 91%