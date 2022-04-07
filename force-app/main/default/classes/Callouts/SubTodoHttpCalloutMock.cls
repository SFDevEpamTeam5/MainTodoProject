@isTest
global class SubTodoHttpCalloutMock implements HttpCalloutMock{
    public String BODY = '';
    public void setBody(Id subtodoId){
            this.BODY = '{"' + subtodoId + '" : "a008c00000a9NHOAA1"}';  
    }
    global HttpResponse respond(HttpRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody(BODY);
        resp.setStatusCode(200);

        return resp;
    }
}
