public class CallSubTodoRestService {
    
    private static String restServiceOrg = 'https://mycompany-c1-dev-ed.my.salesforce.com/services/apexrest/SubTodo/';

    //get
    public static SubToDo__c getSubTodo(Id subTodoId) {
        HttpResponse response = ConnectHelper.makeRequest('GET', null, subTodoId, restServiceOrg);
        SubToDo__c resSub = new SubToDo__c();
        if (response.getStatusCode() == 200) {
            String body = response.getBody();
        	if(body == ''){
            	System.debug('No Todo');
        		return null;    
        		}
            resSub = (SubToDo__c)JSON.deserialize(response.getBody(), SubToDo__c.class);
        	}
        
        return resSub;        
    }
    //post
    public static List<SubToDo__c> callPost(List<SubToDo__c> subtodoList){
        String JSONString = JSON.serialize(subtodoList);

        HttpResponse response = ConnectHelper.makeRequest('POST', JSONString, null, restServiceOrg);
         
        System.debug(response.getStatusCode() + ' ' + response.getBody());
        
        if (response.getStatusCode() == 200) {
            System.debug('Code 200');
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        	List<SubToDo__c> subtodoListOrigin = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c WHERE Id IN : resMap.keySet()];
        	for(SubToDo__c t : subtodoListOrigin){
            	t.Id_SubTodo_from_another_org__c = (String)resMap.get(String.valueOf(t.Id));
        	}
        	if (subtodoListOrigin.size() > 0) update subtodoListOrigin;         
        	return subtodoListOrigin;
        	}
        return null;            
    }
    	//delete
        public static List<String> callDelete(List<ID> idSubTodoFromAnotherOrg){
        
        List<String> listUndeletedTodoFromanotherOrg = new List<String>();    
        
        String JSONString = JSON.serialize(idSubTodoFromAnotherOrg);

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
    public static Map<Id, String> callPatch(List<SubToDo__c> listSubTodosForUpdate){
        
        Map<Id, String> mapResultFromResponse = new Map<Id, String>();
                 
        String JSONString = JSON.serialize(listSubTodosForUpdate);

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
    public static Map<Id, String> callPut(List<SubToDo__c> listTodosForUpdate){
        
        Map<Id, String> mapResultFromResponse = new Map<Id, String>();
        Map<Id, Id> subtodosWereCreated = new Map<Id, Id>();
            
        
        String JSONString = JSON.serialize(listTodosForUpdate);
        HttpResponse response = ConnectHelper.makeRequest('PUT', JSONString, null, restServiceOrg);
        
        if (response.getStatusCode() == 200) {
            
            System.debug(response.getBody());
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            for(String str : resMap.keySet()){
                String res = (String)resMap.get(str);
                Id subtodoId = (Id)str;
                if(res.contains('record created')){
                    String idCreatedTodo = res.substring(res.lastIndexOf(':') + 1).trim();
                    mapResultFromResponse.put(str, 'record created');
                    subtodosWereCreated.put((Id)str, (Id)idCreatedTodo);
                    if(subtodosWereCreated.size() > 0){
                        updateSubTodos(subtodosWereCreated);
                    }
                }
                mapResultFromResponse.put(subtodoId, res);       
            }
        }
            if(mapResultFromResponse.size() > 0){
                return mapResultFromResponse;
            }
        return null;            
    }
          
    public static void updateSubTodos(Map<Id, Id> subtodosWereCreated){
        List<SubToDo__c> subtodoListOrigin = [SELECT Id, Name, Id_SubTodo_from_another_org__c, IsDone__c, ToDo__c FROM SubToDo__c WHERE Id IN : subtodosWereCreated.keySet()];
        for(SubToDo__c sid : subtodoListOrigin){
            sid.Id_SubTodo_from_another_org__c = subtodosWereCreated.get(sid.Id);
        }
        update subtodoListOrigin;
    }
}

//test 92%