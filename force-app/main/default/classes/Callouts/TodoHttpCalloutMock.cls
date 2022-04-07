@isTest
global class TodoHttpCalloutMock implements HttpCalloutMock{
    public String BODY = '';
    public void setBody(Id todoId){
            this.BODY = '{"' + todoId + '" : "a008c00000a9UHWAA2"}';  
    }
    global HttpResponse respond(HttpRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody(BODY);
        resp.setStatusCode(200);

        return resp;
    }
}
