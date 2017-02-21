import ballerina.lang.messages;

@http:BasePath("/widgets")
service WidgetInventoryMockService {
	
	@http:GET
	resource inquire(message m) {
		message response = {};
		json payload = `{"inquire":"widget","availability":"true"}`;
		messages:setJsonPayload(response, payload);
		reply response;
		
	}
	
}
