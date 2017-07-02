import ballerina.doc;
import org.wso2.ballerina.connectors.oauth2;
import ballerina.net.http;
import  ballerina.lang.messages;
import ballerina.lang.jsons;

@doc:Description { value: "api.ai client connector."}
@doc:Param { value: "accessToken: Value of the valid access_token."}
@doc:Param { value: "timeZone: The value of the time zone i.e GMT, EST"}
@doc:Param { value: "language: The value of the language type i.e en etc"}
@doc:Param { value: "apiVersion: The version of the API to be called in the format YYYYMMDD"}
connector NlpClientConnector (string accessToken, string timeZone, string language, string apiVersion) {
    
    string baseQueryUri = "https://api.api.ai/api";
    string timeZoneValue = timeZone;
    string languageValue = language;
    string apiVersionValue = apiVersion;

    oauth2:ClientConnector apiAiEp = create oauth2:ClientConnector(baseQueryUri,accessToken,"null","null","null","null");
    
    @doc:Description { value: "query from api.ai"}
    @doc:Param { value: "connectorImpl: the instance of the connector"}
    @doc:Param { value: "query: the message which will be queried from api.ai"}
    @doc:Param { value: "sessionId: session key provided by the user"}
    @doc:Return { value: "response : the value returned as response from api.ai"}
    action query (NlpClientConnector connectorImpl, string query, int sessionId) (message response) {
        string queryPath = "/query?v=" + apiVersionValue;
        message request = {};
        json requestMessageContent = { "query": [ "xxxx"],"timezone": "xxx","lang": "xxx","sessionId":000000};
        jsons:set(requestMessageContent,"$.query",query);
        jsons:set(requestMessageContent,"$.timezone",timeZoneValue);
        jsons:set(requestMessageContent,"$.timezone",languageValue);
        jsons:set(requestMessageContent,"$.sessionId",sessionId);
        messages:setJsonPayload(request, requestMessageContent);
        response = oauth2:ClientConnector.post(apiAiEp,queryPath,request);
        
        return response; 
    }
}

@doc:Description { value: "processors pizza order requests"}
@http:config { basePath: "/pizza"}
service<http> PizzaOrderService {

    @http:POST {}
    resource order (message requestMessage) {
        NlpClientConnector nlp = create NlpClientConnector("16ea21efc5de41b4a106c4ffe303bcac","EST","fr","20150910");
        json requestPayload = messages:getJsonPayload(requestMessage);
        string query = jsons:getString(requestPayload,"$.details");
        int session = jsons:getInt(requestPayload,"$.session");
        message nlpResponse = NlpClientConnector.query(nlp,query,session);
        message response = {};
        
        json nlpResponsePayload = messages:getJsonPayload(nlpResponse);
        
        boolean inComplete = jsons:getBoolean(nlpResponsePayload,"$.result.actionIncomplete");
        string sessionId = jsons:getString(nlpResponsePayload,"$.sessionId");
        
        
        if(!inComplete){
            json completeResponse = {"status":"complete","details":"xxxx","session":"xxxx"};
            json parameters = jsons:getJson(nlpResponsePayload,"$.result.parameters");
            jsons:set(completeResponse,"$.details",parameters);
            jsons:set(completeResponse,"$.session",sessionId);
            messages:setJsonPayload(response, completeResponse);
        }else{
            json pendingResponse = {"status":"pending","reason":"xxxx","session":"xxxx"};
            string fullfilment = jsons:getString(nlpResponsePayload,"$.result.fulfillment.speech");
            jsons:set(pendingResponse,"$.reason",fullfilment);
            jsons:set(pendingResponse,"$.session",sessionId);
            messages:setJsonPayload(response, pendingResponse);
        }
        
        reply response;
    }
}
