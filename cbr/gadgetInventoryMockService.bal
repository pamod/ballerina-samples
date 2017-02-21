import ballerina.lang.messages;

@http:BasePath("/gadgets")
service GadgetInventoryMockService {
	
	@http:GET
	resource inquire(message m) {
		message response = {};
		json payload = `{"inquire":"gadget","availability":"true"}`;
		messages:setJsonPayload(response, payload);
		reply response;
		
	}
	
}
