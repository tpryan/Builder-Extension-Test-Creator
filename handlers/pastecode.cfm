<cfsavecontent variable="codeToPaste">

&lt;cfif not structKeyExists(form, "ideeventInfo")&gt;
	&lt;cffile action="read" file="#ExpandPath('./sample.xml')#" variable="ideeventInfo" /&gt;
&lt;/cfif&gt;

</cfsavecontent>
<cfset codeToPaste = replaceList(codeToPaste, "&gt;,&lt;", ">,<") />

<cfheader name="Content-Type" value="text/xml">
<response showresponse="yes">
	<ide >			
		<commands>			
			<command type="inserttext">
				<params>
					<param key="text">
						<![CDATA[
						<cfoutput>
							#codeTopaste#
						</cfoutput>
						]]>
					</param>
				</params>
				
			</command>
			
		</commands>
	</ide>
</response>