@RestResource(urlMapping='/SubTodo/*')
global with sharing class SubTodoAPI {
    @HttpGet
    global static SubToDo__c doGet() {
        RestRequest req = RestContext.request;
        String subtodoId = getId(req);
        List<SubToDo__c> result = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c WHERE Id = :subtodoId];
        if(result.size() > 0) return result[0];
        return null;   
    }
    
    @HttpPost
    global static Map<String, String> doPost(){
        RestRequest req = RestContext.request;
        List<SubToDo__c> subtodoList = getListFromBody(req);
   
        List<SubToDo__c> subTodoForInsert = createListOfSubTodos(subtodoList);
        System.debug(subTodoForInsert);
        if(subTodoForInsert.size() > 0){
            Map<String, String> resMap = new Map<String, String>();
            Database.SaveResult[] srList = Database.insert(subTodoForInsert, false);
            for (Integer i = 0; i < subTodoForInsert.size(); i++) {
    		Database.SaveResult sr = srList[i];
    		SubTodo__c origRecord = subTodoForInsert[i];
                if (sr.isSuccess()){
                    resMap.put(origRecord.Id_SubTodo_from_another_org__c, sr.getId());
                }
    			if (!sr.isSuccess()) {
                    String errors = string.join(sr.getErrors(),',');
        			resMap.put(origRecord.Id_SubTodo_from_another_org__c, errors);
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
        List<SubToDo__c> listForDelete = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c WHERE Id IN : idList];
        
        if(listForDelete.size() > 0){
            List <Database.DeleteResult> srList = Database.delete(listForDelete, false);
            for (Integer i = 0; i < listForDelete.size(); i++) {
    		Database.DeleteResult s = srList[i];
    		SubTodo__c origRecord = listForDelete[i];
                if (s.isSuccess()){
                    resMap.put(origRecord.Id_SubTodo_from_another_org__c, 'deleted');
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_SubTodo_from_another_org__c, errors);
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
        List<SubTodo__c> subtodoList = getListFromBody(req);
        List<SubTodo__c> forUpdate = createListOfSubTodos(subtodoList);                         
        if(forUpdate.size() > 0){
            Database.SaveResult[] srList = Database.update(forUpdate, false);
            for (Integer i = 0; i < forUpdate.size(); i++) {
    		Database.SaveResult s = srList[i];
    		SubTodo__c origRecord = forUpdate[i];
                if (s.isSuccess()){
                    resMap.put(origRecord.Id_SubTodo_from_another_org__c, 'updating succses');
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_SubTodo_from_another_org__c, errors);
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
        List<SubTodo__c> todoList = getListFromBody(req);
        List<SubTodo__c> forUpdate = createListOfSubTodos(todoList);                         
        if(forUpdate.size() > 0){
            System.debug('forUpdate ' + forUpdate);
            Database.UpsertResult[] srList = Database.upsert(forUpdate, false);
            for (Integer i = 0; i < forUpdate.size(); i++) {
    		Database.UpsertResult s = srList[i];
    		SubTodo__c origRecord = forUpdate[i];
                if (s.isSuccess()){
                    if(!s.isCreated()){
                        resMap.put(origRecord.Id_SubTodo_from_another_org__c, 'updating succses');
                    }
                    	resMap.put(origRecord.Id_SubTodo_from_another_org__c, 'record created :' + s.getId());     
                }
    			if (!s.isSuccess()) {
                    String errors = string.join(s.getErrors(),',');
        			resMap.put(origRecord.Id_SubTodo_from_another_org__c, errors);
     			}           
        	}
            return resMap;
     	}
    	return null;
    }

    @TestVisible
    private static List<SubToDo__c> createListOfSubTodos(List<SubToDo__c> subtodoList){
        List<SubToDo__c> createList = new List<SubToDo__c>();
        Map<Id,Id> idSubIdTodoMap = new Map<Id,Id>();
        Map<Id,Id> IdTodoSOurceidTodoOrig = new Map<Id,Id>();
        for(SubToDo__c s : subtodoList){
            idSubIdTodoMap.put(s.Id, s.Todo__c);      
        } 
        Map<Id, Todo__c> masterTodo = new Map<Id, Todo__c>([SELECT ID, Name, Id_Todo_from_another_org__c FROM Todo__c WHERE Id_Todo_from_another_org__c IN : idSubIdTodoMap.values()]);
        for(Id i : masterTodo.keySet()){
            IdTodoSOurceidTodoOrig.put( masterTodo.get(i).Id_Todo_from_another_org__c, i );
        }
        for(SubToDo__c s : subtodoList){
            Id another = s.Id;
            String idFromAnotherOrg = s.Id_SubTodo_from_another_org__c;
            String masterTodoForSub = s.Todo__c;
            if(String.isNotEmpty(s.Id_SubTodo_from_another_org__c)){
                s.Id = s.Id_SubTodo_from_another_org__c;   
            }
            s.Id_SubTodo_from_another_org__c = another;
            s.Insert_from_remote_org__c = true;
            s.Todo__c = IdTodoSOurceidTodoOrig.get((Id)masterTodoForSub);
            Map<String, Object> subtoDotMap1 = new Map<String, Object>(s.getPopulatedFieldsAsMap());
		    subtoDotMap1.remove( 'OwnerId' );
            if (String.isEmpty(idFromAnotherOrg)){
                subtoDotMap1.remove( 'Id' );
            }
		    SubToDo__c newSubTodo = (SubToDo__c) JSON.deserialize( JSON.serialize( subtoDotMap1 ), SubToDo__c.class );
            createList.add(newSubTodo);
        }
        return createList;
        
    }

    @TestVisible
    private static List<SubToDo__c> getListFromBody(RestRequest req){
        Blob jsonTodoString = req.requestBody;
        List<SubToDo__c> todoList = (List<SubToDo__c>)JSON.deserialize(jsonTodoString.toString(), List<SubToDo__c>.class);
        return todoList;
    }

    @TestVisible
    private static String getId(RestRequest req){
        String subtodoId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return subtodoId;
    }
}

