public class CallTodoRestService {
	
    private static String restServiceOrg = 'https://mycompany-c1-dev-ed.my.salesforce.com/services/apexrest/Todo/';

    //get
    public static Todo__c getTodo(Id todoId) {
        HttpResponse response = ConnectHelper.makeRequest('GET', null, todoId, restServiceOrg);
        Todo__c resAcc = new Todo__c();
        if (response.getStatusCode() == 200) {
            String body = response.getBody();
        	if(body == ''){
            	System.debug('No Todo');
        		return null;    
        		}
            resAcc = (Todo__c)JSON.deserialize(response.getBody(), Todo__c.class);
        	}
        
        System.debug(resAcc);
        return resAcc;        
    }
    //post
    public static List<Todo__c> callPost(List<Todo__c> todoList){
        String JSONString = JSON.serialize(todoList);

        HttpResponse response = ConnectHelper.makeRequest('POST', JSONString, null, restServiceOrg);
               
        if (response.getStatusCode() == 200) {
            System.debug('Code 200');
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        	List<Todo__c> todoListOrigin = [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
                          IsDone__c, RecordTypeId, Status__c, 
                          Id_Todo_from_another_org__c FROM Todo__c WHERE Id IN : resMap.keySet()];
        	for(Todo__c t : todoListOrigin){
            	t.Id_Todo_from_another_org__c = (String)resMap.get(String.valueOf(t.Id));
        	}
        	if (todoListOrigin.size() > 0) update todoListOrigin;         
        	return todoListOrigin;
        	}
        return null;            
    }
    	//delete
        public static List<String> callDelete(List<ID> idTodoFromAnotherOrg){
        
        List<String> listUndeletedTodoFromanotherOrg = new List<String>();    
        
        String JSONString = JSON.serialize(idTodoFromAnotherOrg);

        HttpResponse response = ConnectHelper.makeRequest('DELETE', JSONString, null, restServiceOrg);
        String responseBody = response.getBody();
        if(String.isEmpty(responseBody)){
            System.debug('Nothing delete');
            return null;
        }
        if (response.getStatusCode() == 200) {
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            for(String str : resMap.keySet()){
                String res = (String)resMap.get(str);
                if(res != 'deleted'){   
                    listUndeletedTodoFromanotherOrg.add(res);
                }        
            }
        }
            if(listUndeletedTodoFromanotherOrg.size() > 0){
                return listUndeletedTodoFromanotherOrg;
            }
        return null;            
    }
    //update
    public static Map<Id, String> callPatch(List<Todo__c> listTodosForUpdate){
        
        Map<Id, String> mapResultFromResponse = new Map<Id, String>();
                 
        String JSONString = JSON.serialize(listTodosForUpdate);

        HttpResponse response = ConnectHelper.makeRequest('PATCH', JSONString, null, restServiceOrg);

        if (response.getStatusCode() == 200) {
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            for(String str : resMap.keySet()){
                String res = (String)resMap.get(str);
                Id todoId = (Id)str; 
                mapResultFromResponse.put(todoId, res);       
            }
        }
            if(mapResultFromResponse.size() > 0){
                return mapResultFromResponse;    
            }
        return null;            
    }
    //upsert
    public static Map<Id, String> callPut(List<Todo__c> listTodosForUpdate){
        
        Map<Id, String> mapResultFromResponse = new Map<Id, String>();
        Map<Id, Id> todosWereCreated = new Map<Id, Id>();
            
        
        String JSONString = JSON.serialize(listTodosForUpdate);
        HttpResponse response = ConnectHelper.makeRequest('PUT', JSONString, null, restServiceOrg);
        
        if (response.getStatusCode() == 200) {
            
            System.debug(response.getBody());
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            for(String str : resMap.keySet()){
                String res = (String)resMap.get(str);
                Id todoId = (Id)str;
                if(res.contains('record created')){
                    String idCreatedTodo = res.substring(res.lastIndexOf(':') + 1).trim();
                    mapResultFromResponse.put(str, 'record created');
                    todosWereCreated.put((Id)str, (Id)idCreatedTodo);
                    if(todosWereCreated.size() > 0){
                        updateTodos(todosWereCreated);
                    }
                }
                mapResultFromResponse.put(todoId, res);       
            }
        }
            if(mapResultFromResponse.size() > 0){
                return mapResultFromResponse;
            }
        return null;            
    }
          
    public static void updateTodos(Map<Id, Id> todosWereCreated){
        List<Todo__c> todoListOrigin = [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
                          IsDone__c, RecordTypeId, Status__c, 
                          Id_Todo_from_another_org__c FROM Todo__c WHERE Id IN : todosWereCreated.keySet()];
        for(Todo__c tid : todoListOrigin){
            tid.Id_Todo_from_another_org__c = todosWereCreated.get(tid.Id);
        }
        update todoListOrigin;
    }
    
        
}