<cfcomponent name="graph">
	<cfprocessingdirective pageencoding="utf-8">

	<cffunction name="getToken" returntype="struct" access="public" hint="Log to the Microsoft network and produce the token that will be used with the other services">
		
		<cfset local.return = structNew()>

		<cfset private.url = "https://login.microsoftonline.com/#application.graph.user.tenantID#/oauth2/v2.0/token">

		<cftry>
			<cfhttp method="post" charset="utf-8" url="#private.url#" result="token">

				<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="formfield" name="grant_type"  value="password">
				<cfhttpparam type="formfield" name="client_id" 	 value="#application.graph.user.clientID#">
				<cfhttpparam type="formfield" name="client_secret" value="#application.graph.user.clientSecret#">
				<cfhttpparam type="formfield" name="scope" value="https://graph.microsoft.com/.default">
				<cfhttpparam type="formfield" name="userName" value="#application.graph.user.email#">
				<cfhttpparam type="formfield" name="password" value="#application.graph.user.password#">

			</cfhttp>

			<cfset jsonTokenResposta = token.filecontent>

			<cfif isJSON(jsonTokenResposta)>
				<cfset local.return.code = left(token.statusCode, 3)>
				<cfset local.return.message = right(token.statusCode, len(token.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonTokenResposta)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = token>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="searchDirectoryByName" returntype="struct" access="public" hint="Return one or more directories with the name searched. If sent with the name in black will return all directories">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="name" type="string" default="">
		
		<cfset local.return = structNew()>

		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/root/children/#arguments.name#">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">
				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="createDirectory" returntype="struct" access="public" hint="Creates a new directory and return all it´s information">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="directory" type="string" default="">
		
		<cfset local.return = structNew()>

		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/root/children">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="recCreateDirectory">
				{
					"name": "<cfoutput>#arguments.directory#</cfoutput>",
					"folder": {}
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#recCreateDirectory#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="deleteDirectory" returntype="struct" access="public" hint="Delete a directory and it´s contents">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/items/#arguments.id#">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="delete" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="uploadFile" returntype="struct" access="public" hint="Send a file to a directory - maximum upload limit 4mb (It´s Microsoft, not me!)">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="drive" type="struct" default="">
		<cfargument required="true" name="directory" type="struct" default="">
		<cfargument required="true" name="file" type="struct" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/drives/#drive.id#/items/#directory.id#:/#file.name#:/content">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="put" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="file" name="#file.name#" file="#file.path#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="uploadFilePartStart" returntype="struct" access="public" hint="Start the file upload process. Returns the url and first expected byte range">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="directory" type="struct" default="">
		<cfargument required="true" name="byteLength" type="string" default="">
		<cfargument required="true" name="name" type="string" default="">
		<cfargument required="true" name="description" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/root:/#arguments.directory.name#/#arguments.name#:/createUploadSession">

		<cfsavecontent variable="local.dadosJsonInicioUpload">
			"item":{
				"@microsoft.graph.conflictBehavior": "overwrite",
				"description": "<cfoutput>#arguments.description#</cfoutput>",
				"fileSize": <cfoutput>#arguments.byteLength#</cfoutput>,
				"name": "<cfoutput>#arguments.name#</cfoutput>"
			},
			"deferCommit": false
		</cfsavecontent>
		
		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>
			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">
				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#local.dadosJsonInicioUpload#">
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="uploadFilePart" returntype="struct" access="public" hint="Send the file block to the url produced at the uploadFilePartStart method">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="uploadUrl" type="string" default="">
		<cfargument required="true" name="byteLength" type="string" default="">
		<cfargument required="true" name="start" type="string" default="">
		<cfargument required="true" name="totalBytes" type="string" default="">
		<cfargument required="true" name="load" type="any" default="">
		
		<cfset local.return = structNew()>

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="put" charset="utf-8" url="#arguments.uploadUrl#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/octet-stream">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="header" name="Content-Length" value="#arguments.byteLength#">
				<cfhttpparam type="header" name="Content-Range" value="bytes #arguments.start#-#(arguments.start+arguments.byteLength-1)#/#arguments.totalBytes#">

				<cfhttpparam type="body" value="#arguments.load#">
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="uploadFilePartRestart" returntype="struct" access="public" hint="Restarts the file upload process in case of timeout">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="uploadUrl" type="string" default="">
		
		<cfset local.return = structNew()>

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="put" charset="utf-8" url="#arguments.uploadUrl#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="searchDriveUsers" returntype="struct" access="public" hint="Search users from this Drive">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="email" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/users/#arguments.email#">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="listTeamsChannel" returntype="struct" access="public" hint="List all Microsoft Teams channels">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="getTeamsChannelProperties" returntype="struct" access="public" hint="Returns the properties of a Teams channel">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="getTeamsChannelMembers" returntype="struct" access="public" hint="Returns all channel members">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#/members">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="createChatChannel" returntype="struct" access="public" hint="Creates a new channel chat">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="tipo" type="string" default="">
		<cfargument required="true" name="name" type="string" default="">
		<cfargument required="true" name="description" type="string" default="">
		<cfargument required="true" name="id_usuario" type="string" default="">
		<cfargument required="true" name="papel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="local.dadosJson">
				{
					"@odata.type":"#Microsoft.Graph.channel",
					"membershipType":"<cfoutput>#arguments.tipo#</cfoutput>",
					"displayName":"<cfoutput>#left(arguments.name, 50)#</cfoutput>",
					"description":"<cfoutput>#arguments.description#</cfoutput>",
					"members":[
						{
							"@odata.type":"#microsoft.graph.aadUserConversationMember",
							"user@odata.bind":"https://graph.microsoft.com/v1.0/users/<cfoutput>#arguments.id_usuario#</cfoutput>",
							"roles":["<cfoutput>#arguments.papel#</cfoutput>"]
						}
					]
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#local.dadosJson#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="deleteChatChannel" returntype="struct" access="public" hint="Deletes a channel chat">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="delete" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="addTeamUser" returntype="struct" access="public" hint="Adds a user to a Teams group">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_usuario" type="string" default="">
		<cfargument required="true" name="papel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/members">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="local.dadosJson">
				{
					"@odata.type": "#microsoft.graph.aadUserConversationMember",
					"roles": [
						"<cfoutput>#arguments.papel#</cfoutput>"
					],
					"user@odata.bind": "https://graph.microsoft.com/v1.0/users/<cfoutput>#arguments.id_usuario#</cfoutput>"
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#local.dadosJson#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="addChannelUser" returntype="struct" access="public" hint="Adds a member to a channel">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		<cfargument required="true" name="id_usuario" type="string" default="">
		<cfargument required="true" name="papel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#/members">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="local.dadosJson">
				{
					"@odata.type": "#microsoft.graph.aadUserConversationMember",
					"roles": [
						"<cfoutput>#arguments.papel#</cfoutput>"
					],
					"user@odata.bind": "https://graph.microsoft.com/v1.0/users/<cfoutput>#arguments.id_usuario#</cfoutput>"
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#local.dadosJson#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="sendChatMessage" returntype="struct" access="public" hint="Sends a message to a chat channel">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		<cfargument required="true" name="mensagem" type="string" default="">
		<cfargument required="false" name="titulo" type="string" default="">
		<cfargument required="false" name="mencao" type="any" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#/messages">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="local.dadosJson">
				{
					<cfif (len(trim(arguments.titulo)) gt 0)>
						"subject": "<cfoutput>#arguments.titulo#</cfoutput>",
					</cfif>
					<cfif isStruct(arguments.mencao)>
						"body": {
							"contentType": "html",
							"content": "<cfoutput>#replace(arguments.mensagem, '"', '\"', 'ALL')#</cfoutput> <at id=\"0\"><cfoutput>#arguments.mencao.name#</cfoutput></at>"
						}
						, "mentions": [
							{
								"id": 0,
								"mentionText": "<cfoutput>#arguments.mencao.name#</cfoutput>",
								"mentioned": {
									"application": null,
									"device": null,
									"conversation": null,
									"user": {
										"id": "<cfoutput>#arguments.mencao.id#</cfoutput>",
										"displayName": "<cfoutput>#arguments.mencao.name#</cfoutput>",
										"userIdentityType": "aadUser"
										}
								}
							}
						]
					<cfelse>
						"body": {
							"contentType": "html",
							"content": "<cfoutput>#arguments.mensagem#</cfoutput>"
						}
					</cfif>
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#local.dadosJson#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
				<cfset local.return.dataRequisicao = local.dadosJson>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
				<cfset local.return.dataRequisicao = local.dadosJson>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
				<cfset local.return.dataRequisicao = local.dadosJson>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="listChannelMessages" returntype="struct" access="public" hint="Lists all messages from a channel">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id_teams" type="string" default="">
		<cfargument required="true" name="id_channel" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/teams/#arguments.id_teams#/channels/#arguments.id_channel#/messages">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>

			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="createLinkById" returntype="struct" access="public" hint="Create a public link to a file">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/items/#arguments.id#/createLink">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfsavecontent variable="reqLinkfile">
				{
					"type": "view",
					"scope": "anonymous"
				}
			</cfsavecontent>

			<cfhttp method="post" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">

				<cfhttpparam type="body" value="#reqLinkfile#">
				
			</cfhttp>
			
			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="downloadById" returntype="struct" access="public" hint="Finds and download a Drive file">
		<cfargument required="true" name="token" type="struct" default="">
		<cfargument required="true" name="id" type="string" default="">
		
		<cfset local.return = structNew()>
		
		<cfset private.url = "https://graph.microsoft.com/v1.0/me/drive/items/#arguments.id#/content">

		<cftry>
			<cfset private.token_type = token.token_type>
			<cfset private.access_token = token.access_token>

			<cfhttp method="get" charset="utf-8" url="#private.url#" result="httpResult">

				<cfhttpparam type="header" name="Content-Type" value="application/json">
				<cfhttpparam type="header" name="SdkVersion" value="postman-graph/v1.0">

				<cfhttpparam type="header" name="Authorization"  value="#private.token_type# #private.access_token#">
				
			</cfhttp>
			
			<cfset jsonResponse = httpResult.filecontent>

			<cfif isJSON(jsonResponse)>
				<cfset local.return.code = left(httpResult.statusCode, 3)>
				<cfset local.return.message = right(httpResult.statusCode, len(httpResult.statusCode) - 3)>
				<cfset local.return.data = deserializeJSON(jsonResponse)>
			<cfelse>
				<cfset local.return.code = "500">
				<cfset local.return.message = "Erro ao consumir o serviço">
				<cfset local.return.data = httpResult>
			</cfif>

			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>





<!---
	<cffunction name="binToStr" returntype="string" access="public">
		<cfargument required="true" name="file" type="binary" default="">
		
		<cfset local.return = "">

		<cftry>
			<cfif isArray(arguments.file)>
				<cfset local.return = arrayToList(arguments.file, '')>
			</cfif>

			<cfcatch type="any">
				<cfset local.return = "Erro ao transformar o binário">
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="splitBin" returntype="string" access="public">
		<cfargument required="true" name="inicio" type="numeric" default="">
		<cfargument required="true" name="quantidade" type="numeric" default="">
		<cfargument required="true" name="file" type="binary" default="">
		
		<cfset local.return = "">

		<cftry>
			<cfif isArray(arguments.file)>
				<cfset private.fileCortado = arraySlice(arguments.file, arguments.inicio, arguments.quantidade)>
				<cfset local.return = arrayToList(private.fileCortado, '')>
			</cfif>

			<cfcatch type="any">
				<cfset local.return = "Erro ao processar o binário">
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="splitBinFile" returntype="struct" access="public">
		<cfargument required="true" name="file" type="binary" default="">
		<cfargument required="true" name="inicio" type="numeric" default="">
		<cfargument required="true" name="termino" type="numeric" default="">
		
		<cfset local.return = structNew()>

		<cftry>
			<cfset local.return.data = "">

			<cfif isArray(arguments.file)>
				<cfset private.fileCortado = arraySlice(arguments.file, arguments.inicio, arguments.termino)>

				Tamanho do envio: <cfdump var="#arrayLen(private.fileCortado)#">
				<cfset local.return.data = listToArray(private.fileCortado, '')>
			</cfif>

			<cfset local.return.code = "200">
			<cfset local.return.message = "OK">
		
			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>

	<cffunction name="splitHexFile" returntype="struct" access="public">
		<cfargument required="true" name="inicio" type="numeric" default="">
		<cfargument required="true" name="termino" type="numeric" default="">
		<cfargument required="true" name="file" type="string" default="">
		
		<cfset local.return = structNew()>

		<cftry>
			<cfset private.inicioUpload = arguments.inicio>
			<cfset private.terminoUpload = (arguments.termino*2)>

			<cfif ((private.inicioUpload mod 2) eq 0)>
				<cfset private.inicioUpload = private.inicioUpload + 1>
			</cfif>
			<cfset private.file = mid(arguments.file, private.inicioUpload, private.terminoUpload)>
			<cfset private.byteArr = BinaryDecode(private.file, 'Hex')>
			<cfset private.byteStr = arrayToList(private.byteArr, '')>

			<cfset local.return.data = private.byteStr>

			<cfset local.return.code = "200">
			<cfset local.return.message = "OK">
		
			<cfcatch type="any">
				<cfset local.return.code = "500">
				<cfset local.return.message = cfcatch.message>
			</cfcatch>
		</cftry>

		<cfreturn local.return>
	</cffunction>
--->
</cfcomponent>
