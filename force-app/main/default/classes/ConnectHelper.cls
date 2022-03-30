public with sharing class ConnectHelper {
    private static String restServiceOrgForToken = 'https://login.salesforce.com';
    private static String restServiceOrg = 'https://epam-1e-dev-ed.lightning.force.com/services/apexrest/Todo/';
    private static String GET = 'GET';
    private static String POST = 'POST';
    private static String PATCH = 'PATCH';
    private static String PUT = 'PUT';
    private static String DELETEM = 'DELETE';
    public static String getAuthToken(){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        RestServiceSettings__c restServ = RestServiceSettings__c.getOrgDefaults();
        String consumerKey = restServ.Consumer_Key__c;
        String consumerSecret = restServ.Consumer_Secret__c;
        String body = 'grant_type=password' + '&client_id='+consumerKey + 
        '&client_secret='+consumerSecret + '&username='+ EncodingUtil.urlEncode(restServ.username__c, 'UTF-8') +
         '&password='+ EncodingUtil.urlEncode(restServ.password__c + restServ.SecurityToken__c, 'UTF-8');
        req.setMethod(POST);
        req.setEndpoint(restServiceOrgForToken + '/services/oauth2/token');
        req.setBody(body);

        HttpResponse response = http.send(req); 
 		       
        while (response.getStatusCode() == 302) {
    	req.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(req);
		}
        ResponceWraper data = (ResponceWraper)JSON.deserialize(response.getBody(), ResponceWraper.class);

        return data.access_token;       
    }

    public static HttpResponse makeRequest(String methodName, String body, String todoId, String endPoint){

        String token = getAuthToken();
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        String setName = '';
        switch on methodName {
            when  'GET'{
                setName = GET;
            }
            when  'POST'{
                setName = POST;
            }
            when  'PATCH'{
                setName = PATCH;
            }
            when  'PUT'{
                setName = PUT;
            }
            when  'DELETE'{
                setName = DELETEM;
            }
            when else {
                setName = '';
            }
        }
        request.setMethod(setName);
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type', 'application/json');
        if(todoId != null){
            request.setEndpoint(endPoint + todoId);
        }
        request.setEndpoint(endPoint);
        if(body != null){
            request.setBody(body);
        }
        HttpResponse response = http.send(request); 
 		       
        while (response.getStatusCode() == 302) {
    	request.setEndpoint(response.getHeader('Location'));
    	response = new Http().send(request);
		}
        return response;
    }

    public class ResponceWraper {
        public String access_token {get;set;}
        public String id {get;set;}
        public String token_type {get;set;}
    }
}