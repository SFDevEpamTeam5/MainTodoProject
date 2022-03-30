public class CallRestService {
	private static String restServiceOrg = 'https://login.salesforce.com';
    
    public static String getAuthToken(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        RestServiceSettings__c restServ = RestServiceSettings__c.getOrgDefaults();
        String consumerKey = restServ.Consumer_Key__c;
        String consumerSecret = restServ.Consumer_Secret__c;
        req.setMethod('POST');
        req.setEndpoint(restServiceOrg + '/services/oauth2/token');
        req.setBody('grant_type=password' + '&client_id='+consumerKey + 
                    '&client_secret='+consumerSecret + '&username='+ EncodingUtil.urlEncode(restServ.username__c, 'UTF-8') + '&password='+ EncodingUtil.urlEncode(restServ.password__c + restServ.SecurityToken__c, 'UTF-8'));
                       
        HTTPResponse response = http.send(req);
        
        while (response.getStatusCode() == 302) {
    	req.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(req);
		}
 
        ResponceWraper data = (ResponceWraper)JSON.deserialize(response.getBody(), ResponceWraper.class);

        return data.access_token;       
    }
    
    //get
    public static Todo__c getTodo(Id todoId) {
        String token = getAuthToken();
 		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/' + todoId);
 
        HttpResponse response = http.send(request); 
 		       
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
		}
        Todo__c resAcc = new Todo__c();
        if (response.getStatusCode() == 200) {
            String body = response.getBody();
        	if(body == ''){
            	System.debug('No Todo');
        		return null;    
        		}
            resAcc = (Todo__c)JSON.deserialize(response.getBody(), Todo__c.class);
        	}
        
        System.debug('OUt');
        return resAcc;        
    }
    //post
    public static List<Todo__c> callPost(List<Todo__c> todoList){
                      
        String token = getAuthToken();
 		Http http = new Http();
        HttpRequest request = new HttpRequest();
        String JSONString = JSON.serialize(todoList);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/');
 		request.setBody(JSONString);
        
        HttpResponse response = http.send(request); 
                    
        System.debug(JSONString);
        
        System.debug('Calling post service');
        
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
		}
        System.debug(response.getStatusCode() + ' ' + response.getBody());
        
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
            
        String token = getAuthToken();
 		Http http = new Http();
        HttpRequest request = new HttpRequest();
        String JSONString = JSON.serialize(idTodoFromAnotherOrg);
        request.setMethod('DELETE');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/');
 		request.setBody(JSONString);
        
        HttpResponse response = http.send(request); 
                    
        System.debug(JSONString);
        
        System.debug('Calling delete service');
        
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
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
            
        String token = getAuthToken();
 		Http http = new Http();
        HttpRequest request = new HttpRequest();
        String JSONString = JSON.serialize(listTodosForUpdate);
        request.setMethod('PATCH');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/');
 		request.setBody(JSONString);
        
        HttpResponse response = http.send(request); 
      
        System.debug('Calling patch service');
        
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
		}
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
        List<Todo__c> todoForUpdate = new List<Todo__c>();
        Map<Id, Id> todosWereCreated = new Map<Id, Id>();
            
        String token = getAuthToken();
 		Http http = new Http();
        HttpRequest request = new HttpRequest();
        String JSONString = JSON.serialize(listTodosForUpdate);
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/');
 		request.setBody(JSONString);
        
        HttpResponse response = http.send(request); 
                    
        System.debug(JSONString);
        
        System.debug('Calling put service');
        
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
		}
        
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
    
    
    public static List<Todo__c> getListT(){
        return [SELECT Id, Name, Category__c, Completion_Date__c, Deadline__c,
                          IsDone__c, OwnerId, RecordTypeId, Status__c, 
                          Id_Todo_from_another_org__c FROM Todo__c];
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
    
        public class ResponceWraper {
        public String access_token {get;set;}
        public String id {get;set;}
        public String token_type {get;set;}
    }
}