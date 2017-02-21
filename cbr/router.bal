import ballerina.net.http;
import ballerina.lang.jsons;
import ballerina.lang.messages;

@http:BasePath("/route")
service ContentBasedRouter {
	
	@http:POST
	resource lookup(message m) {
		http:ClientConnector widgetEP = create http:ClientConnector("http://localhost:9090/widgets");
		http:ClientConnector gadgetEP = create http:ClientConnector("http://localhost:9090/gadgets");
		json requestMessage = messages:getJsonPayload(m);
		string inventoryType = jsons:getString(requestMessage, "$.type");
		message response = {};
		if (inventoryType == "gadget") {
			response = http:ClientConnector.get(gadgetEP, "/", m);
			
		}
		else {
			response = http:ClientConnector.get(widgetEP, "/", m);
			
		}
		reply response;
		
	}
	
}
