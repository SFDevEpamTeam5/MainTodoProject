@isTest
global class TodoDeleteHttpCalloutMock  implements HttpCalloutMock{
    public static final String BODY = '{"a008c00000a9NHOAA2" : "not deleted"}';

    global HttpResponse respond(HttpRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setBody(BODY);
        resp.setStatusCode(200);

        return resp;
    }
}
