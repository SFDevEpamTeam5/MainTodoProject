@isTest
public class ConnectHelperTest {
    static final String wrapperString = '{"access_token" : "0123456789ABC", "id" : "RtUy12365", "token_type" : "New"}';
    static final String accessToken = '0123456789ABC';
    static final String idRes = 'RtUy12365';
    static final String tokenType = 'New';
    static final String testToken = 'token';
    static final String endPoint = 'https://login.salesforce.com';
    @isTest static void responceWrapperTest(){
        ConnectHelper.ResponceWraper data = (ConnectHelper.ResponceWraper)JSON.deserialize(wrapperString, ConnectHelper.ResponceWraper.class);
        System.assertEquals(accessToken,data.access_token, 'Wrong access token');
        System.assertEquals(idRes, data.id, 'Wrong transaction Id');
        System.assertEquals(tokenType, data.token_type, 'Wrong token type');
    }

    @isTest static void getAuthTokenTest(){
        String result = ConnectHelper.getAuthToken();
        System.assertEquals(testToken, result, 'Error with get auth token');
    }

    @isTest static void makeRequestGetTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('GET', '{"name" : "Anna"}', 'a008c00000a9NHMSD2', endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }

    @isTest static void makeRequestDeleteTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('DELETE', '{"name" : "a008c00000a9NHMSD2"}', null, endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }
    @isTest static void makeRequestPutTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('PUT', '{"name" : "Anna"}', 'a008c00000a9NHMSD2', endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }

    @isTest static void makeRequestPatchTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('PATCH', '{"name" : "Anna"}', 'a008c00000a9NHMSD2', endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }

    @isTest static void makeRequestPostTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('POST', '{"name" : "Anna"}', 'a008c00000a9NHMSD2', endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }
    @isTest static void makeRequestWrongMethodTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyResponseBodyHttpCalloutMock());
        Test.startTest();
        HttpResponse response = ConnectHelper.makeRequest('OTHER', '{"name" : "Anna"}', 'a008c00000a9NHMSD2', endPoint);
        Test.stopTest();
        String body= response.getBody();
        System.assertEquals(200, response.getStatusCode(), 'Wrong status code');
        System.assertEquals('', body, 'Not empty body');
    }
}
