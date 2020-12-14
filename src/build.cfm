<cfscript>
cfhttp(url = "https://api.cfwheels.org/files/json/v2.2.json");
packet = DeserializeJSON(cfhttp.fileContent);
path = GetDirectoryFromPath(GetCurrentTemplatePath()) & '/snippets.json';

struct = StructNew('linked');
for (func in packet.functions) {
	struct[func.name] = {
		'prefix' = func.name,
		'description' = stripHTML(Trim(func.hint)),
		'body' = ['#func.name#(#buildArguments(func = func, includeOptional = false, editor = 'vscode')#)']
	};
}

FileWrite(path, SerializeJSON(struct));
header name="Content-disposition" value="inline; filename=#GetFileFromPath(path)#" {
};
content file="#path#" type="application/json" deletefile="false" {
};

public string function buildArguments(required struct func, required boolean includeOptional, required string editor) {
	local.returnValue = '';
	local.i = 0;
	for (local.arg in arguments.func.parameters) {
		if (local.arg.required) {
			local.i++;
			// quote string args
			if (local.arg.type == 'string') {
				local.nameAndValue = '#local.arg.name# = "$#local.i#"';
			} else {
				local.nameAndValue = '#local.arg.name# = $#local.i#';
			}

			local.returnValue = ListAppend(local.returnValue, local.nameAndValue);
		}
	}
	local.returnValue = ListChangeDelims(local.returnValue, ', ');
	return local.returnValue;
}

public string function stripHTML(str) {
	str = ReReplaceNoCase(
		str,
		'<*style.*?>(.*?)</style>',
		'',
		'ALL'
	);
	str = ReReplaceNoCase(
		str,
		'<*script.*?>(.*?)</script>',
		'',
		'ALL'
	);
	str = ReReplaceNoCase(str, '<.*?>', '', 'ALL');
	// get partial html in front
	str = ReReplaceNoCase(str, '^.*?>', '');
	// get partial html at end
	str = ReReplaceNoCase(str, '<.*$', '');
	return Trim(str);
}
</cfscript>
