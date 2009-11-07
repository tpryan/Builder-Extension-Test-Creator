<cfset ideResults = manipulateIDEXML(form.ideeventInfo) />
<cffile action="write" file="#ideResults.fileLocation#" output="#ideResults.humanreadable#"  />

<cfheader name="Content-Type" value="text/xml">
<response status="success" showresponse="true">
	<ide >
		<dialog width="600" height="400" />
			<body>
				<![CDATA[
				<p>The following content was written to <cfoutput>#ideResults.fileLocation#</cfoutput><p>
				<cfdump var="#ideResults.xmlObj#">
				]]>
			</body>
	</ide>
</response>


<cffunction name="manipulateIDEXML" output="FALSE" access="public"  returntype="struct" hint="" >
	<cfargument name="XML" type="string" required="TRUE" hint="The formXML to manipulate" />
	
	<cfset var results = StructNew() />
	<cfset var xmldoc = XMLParse(arguments.XML) />
	<cfset var folderPath = XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_path']")[1].XMLAttributes.value />
	<cfset var fileName = XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_file']")[1].XMLAttributes.value />
	<cfset var userAdditions = XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_formsim']")[1].XMLAttributes.value />

	<cfif listLen(userAdditions) gt 0> 
		<cfloop list="#userAdditions#" index="keyPair">
			<cfset name = Trim(getToken(keypair,1,"=")) />
			<cfset value = getToken(keypair,2,"=") />
			<cfset node =  XmlElemNew(xmldoc, "input") />
			<cfset StructInsert(node.XmlAttributes, "name", name) />
			<cfset StructInsert(node.XmlAttributes, "value", value) />
	
			<cfset ArrayAppend(xmldoc.event.user.xmlChildren, node) />
		</cfloop>
	</cfif>
	
	<cfset XmlDeleteNodesJava(xmldoc,XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_path']") ) />
	<cfset XmlDeleteNodesJava(xmldoc,XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_file']") ) />
	<cfset XmlDeleteNodesJava(xmldoc,XMLSearch(xmldoc, "/event/user/input[@name='cfbtc_formsim']") ) />

	<cfset results.fileLocation = "#folderPath#/#fileName#" />
	<cfset results.humanreadable = xmlHumanReadable(xmldoc) />
	<cfset results.xmlObj = xmldoc />
	
	<cfreturn results />
</cffunction>



<cfscript>
/**
* Formats an XML document for readability.
* update by Fabio Serra to CR code
*
* @param XmlDoc      XML document. (Required)
* @return Returns a string.
* @author Steve Bryant (steve@bryantwebconsulting.com)
* @version 2, March 20, 2006
*/
function xmlHumanReadable(XmlDoc) {
    var elem = "";
    var result = "";
    var tab = "    ";
    var att = "";
    var i = 0;
    var temp = "";
    var cr = createObject("java","java.lang.System").getProperty("line.separator");
    
    if ( isXmlDoc(XmlDoc) ) {
        elem = XmlDoc.XmlRoot;//If this is an XML Document, use the root element
    } else if ( IsXmlElem(XmlDoc) ) {
        elem = XmlDoc;//If this is an XML Document, use it as-as
    } else if ( NOT isXmlDoc(XmlDoc) ) {
        XmlDoc = XmlParse(XmlDoc);//Otherwise, try to parse it as an XML string
        elem = XmlDoc.XmlRoot;//Then use the root of the resulting document
    }
    //Now we are just working with an XML element
    result = "<#elem.XmlName#";//start with the element name
    if ( StructKeyExists(elem,"XmlAttributes") ) {//Add any attributes
        for ( att in elem.XmlAttributes ) {
            result = '#result# #att#="#XmlFormat(elem.XmlAttributes[att])#"';
        }
    }
    if ( Len(elem.XmlText) OR (StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren)) ) {
        result = "#result#>#cr#";//Add a carriage return for text/nested elements
        if ( Len(Trim(elem.XmlText)) ) {//Add any text in this element
            result = "#result##tab##XmlFormat(Trim(elem.XmlText))##cr#";
        }
        if ( StructKeyExists(elem,"XmlChildren") AND ArrayLen(elem.XmlChildren) ) {
            for ( i=1; i lte ArrayLen(elem.XmlChildren); i=i+1 ) {
                temp = Trim(XmlHumanReadable(elem.XmlChildren[i]));
                temp = "#tab##ReplaceNoCase(trim(temp), cr, "#cr##tab#", "ALL")#";//indent
                result = "#result##temp##cr#";
            }//Add each nested-element (indented) by using recursive call
        }
        result = "#result#</#elem.XmlName#>";//Close element
    } else {
        result = "#result# />";//self-close if the element doesn't contain anything
    }
    
    return result;
}
</cfscript>


<!--- Code taken from Ben Nadel http://www.bennadel.com/blog/1236-Deleting-XML-Node-Arrays-From-A-ColdFusion-XML-Document.htm --->
<cffunction name="XmlDeleteNodesJava" access="public" returntype="void" output="false" hint="I remove a node or an array of nodes from the given XML document.">
	<cfargument name="XmlDocument" type="any" required="true" hint="I am a ColdFusion XML document object." />
	<cfargument name="Nodes" type="any" required="false" hint="I am the node or an array of nodes being removed from the given document." />
 
	<cfset var LOCAL = StructNew() />
 
	<cfif NOT IsArray( ARGUMENTS.Nodes )>
		<cfset LOCAL.Node = ARGUMENTS.Nodes />
		<cfset ARGUMENTS.Nodes = [ LOCAL.Node ] />
	</cfif>
 
 
	<!--- Loop over the nodes. --->
	<cfloop index="LOCAL.Node" array="#ARGUMENTS.Nodes#">
 
		<!--- Get the parent node. --->
		<cfset LOCAL.ParentNode = LOCAL.Node.GetParentNode() />
 
		<cfif StructKeyExists( LOCAL, "ParentNode" )>
			<cfset LOCAL.PrevNode = LOCAL.Node.GetPreviousSibling() />
 
			<cfif StructKeyExists( LOCAL, "PrevNode" )>
				<cfset LOCAL.ParentNode.RemoveChild(LOCAL.PrevNode.GetNextSibling() ) />
			<cfelse>
				<cfset LOCAL.ParentNode.RemoveChild(LOCAL.ParentNode.GetFirstChild()) />
			</cfif>
		</cfif>
 
	</cfloop>
 
</cffunction>