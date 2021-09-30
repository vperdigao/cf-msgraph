
<!doctype html>
<html lang="en">
<head>
</head>
<body>


<cfset cfcGraph = new graph()>

<cfdump var="#cfcGraph#" label="cfcGraph">

<cfset token = cfcGraph.getToken()>

<cfdump var="#token#" label="token">

<cfset directorySearch = cfcGraph.searchDirectoryByName(
										token: token.data,
										name: ''
									)>

<cfdump var="#directorySearch#" label="directorySearch">

<cfset createDir = cfcGraph.createDirectory(
										token: token.data,
										directory: 'myTest'
									)>

<cfdump var="#createDir#" label="createDir">

<cfset directorySearchCreated = cfcGraph.searchDirectoryByName(
										token: token.data,
										name: 'myTest'
									)>

<cfdump var="#directorySearchCreated#" label="directorySearchCreated">

<cfif (directorySearchCreated.code eq "200")>

	<cfset deleteDir = cfcGraph.deleteDirectory(
											token: token.data,
											id: directorySearchCreated.data['id']
										)>

	<cfdump var="#deleteDir#" label="deleteDir">

</cfif>

<cfset directorySearchDeleted = cfcGraph.searchDirectoryByName(
										token: token.data,
										name: 'myTest'
									)>

<cfdump var="#directorySearchDeleted#" label="directorySearchDeleted">

<cfset searchDestinationDirectory = cfcGraph.searchDirectoryByName(
										token: token.data,
										name: 'gestao_acervo_dev'
									)>

<cfdump var="#searchDestinationDirectory#" label="searchDestinationDirectory">

<cfset drive = structNew()>
<cfset drive.id = searchDestinationDirectory.data['parentReference']['driveId']>

<cfset file = GetFileInfo("#expandPath('.')#\img\example.jpg")>
<cffile action="readbinary" file="#file.path#" variable="file.bin">

<cfset uploadSmallFile = cfcGraph.uploadFile(
										token: token.data,
										drive: drive,
										directory: searchDestinationDirectory.data,
										file: file
									)>

<cfdump var="#uploadSmallFile#" label="uploadSmallFile">

<cfset bigFileUploadInit = cfcGraph.uploadFilePartStart(
										token: token.data,
										directory: searchDestinationDirectory.data,
										name: file.name,
										description: 'your file description',
										byteLength: file.size
									)>

<cfdump var="#bigFileUploadInit#" label="bigFileUploadInit">

<cfset uploadBlock = structNew()>
<cfset uploadBlock.code = bigFileUploadInit.code>
<cfset uploadBlock.message = bigFileUploadInit.message>

Define starting size
<cfset loadSize = 1>

Create the buffer
<cfset objByteBuffer = CreateObject(
							"java",
							"java.nio.ByteBuffer"
						)>

Alocate full file space
<cfset objBuffer = objByteBuffer.Allocate(
	JavaCast( "int", loadSize )
)>

first part
<cfset objBuffer.Put(
	file.bin,
	JavaCast( "int", 0 ),
	JavaCast( "int", loadSize )
)>

<cfset thisFile = structNew()>
<cfset thisFile.bytes = 1>
<cfset thisFile.start = 0>

<cfset fileLoop = 0>
<cfloop condition="(uploadBlock.message NEQ 'Created')">

	<cfif (left(uploadBlock.code, 2) eq "20")>

		<cfif (fileLoop gt 0)>
			<cfset thisFile.bytes = uploadBlock.data.nextExpectedRanges[1].listGetAt(2,'-')>
			<cfset thisFile.start = uploadBlock.data.nextExpectedRanges[1].listGetAt(1,'-')>
		</cfif>

		Alocate file space
		<cfset objBuffer = objByteBuffer.Allocate(
			JavaCast(
				"int", 
				thisFile.bytes
			)
		)>

		Break the binary
		<cfset objBuffer.Put(
			file.bin,
			JavaCast( "int", thisFile.start ),
			JavaCast( "int", thisFile.bytes )
		)>

		<cfset uploadBlock = cfcGraph.uploadFilePart(
								token: token.data,
								uploadUrl: bigFileUploadInit.data.uploadUrl,
								byteLength: thisFile.bytes,
								start: thisFile.start,
								totalBytes: file.size,
								load: objBuffer.Array()
		)>

		<cfdump var="#uploadBlock#" label="File data - #fileLoop#">

		<cfif (
			(not structKeyExists(uploadBlock.data, 'nextExpectedRanges'))
			&&
			structKeyExists(uploadBlock.data, 'name')
			)>
			End of upload
			<cfbreak>
		</cfif>
	<cfelse>
		Error during file transmission:
		<cfdump var="#serializeJSON(uploadBlock)#" label="uploadBlock">
	</cfif>

	<cfset fileLoop++>

</cfloop>

<p style="font-size: 0.9rem;font-style: italic;"><img style="display: block;" src="https://live.staticflickr.com/3699/13157377715_b0630526c0_b.jpg" alt="XT1 Test"><a href="https://www.flickr.com/photos/84172943@N00/13157377715">"XT1 Test"</a><span> by <a href="https://www.flickr.com/photos/84172943@N00">Daniel Y. Go</a></span> is licensed under <a href="https://creativecommons.org/licenses/by-nc/2.0/?ref=ccsearch&atype=html" style="margin-right: 5px;">CC BY-NC 2.0</a><a href="https://creativecommons.org/licenses/by-nc/2.0/?ref=ccsearch&atype=html" target="_blank" rel="noopener noreferrer" style="display: inline-block;white-space: none;margin-top: 2px;margin-left: 3px;height: 22px !important;"><img style="height: inherit;margin-right: 3px;display: inline-block;" src="https://search.creativecommons.org/static/img/cc_icon.svg?image_id=bdc323df-aaa3-4871-9ce2-b3b13a18f700" /><img style="height: inherit;margin-right: 3px;display: inline-block;" src="https://search.creativecommons.org/static/img/cc-by_icon.svg" /><img style="height: inherit;margin-right: 3px;display: inline-block;" src="https://search.creativecommons.org/static/img/cc-nc_icon.svg" /></a></p>

<script type="text/javascript">

</script>

</body>
</html>