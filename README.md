cf-graph

Instructions:

Create an Application.cfc with your Drive/Sharepoint credentials like the one below:

<cfcomponent>

	<cffunction name="onApplicationStart">
		
		<cfset application.graph.user.tenantID = "">
		<cfset application.graph.user.id = "">
		<cfset application.graph.user.email = "">
		<cfset application.graph.user.password = "">
		<cfset application.graph.user.clientID = "">
		<cfset application.graph.user.clientSecret = "">

	</cffunction>

</cfcomponent>

If you use CommandBox this application will run on http://127.0.0.1:8181

Access /index.cfm to view some usage examples.


Created by Vinicius Perdigão

The picture "XT1 Test" by Daniel Y. Go is licensed under CC BY-NC 2.0
