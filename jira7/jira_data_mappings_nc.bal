
function issueLinkRequestToJson(IssueLinkRequest source) returns json {

    json target = {"application":{},"object":{"icon":{},"status":{"icon":{}}}};

    target.global_id = source.globalId != EMPTY_STRING ? source.globalId : null;
    target.application["type"] = source.applicationType != EMPTY_STRING ? source.applicationType : null;
    target.application.name = source.applicationName != EMPTY_STRING ? source.applicationName : null;

    target["object"].url = source.url != EMPTY_STRING ? source.url : null;
    target["object"].title = source.title != EMPTY_STRING ? source.title : null;
    target["object"].summary = source.summary != EMPTY_STRING ? source.summary : null;
    target["object"].icon.url16x16 = source.iconUrl != EMPTY_STRING ? source.iconUrl : null;
    target["object"].icon.title = source.iconTitle != EMPTY_STRING ? source.iconTitle : null;

    target["object"].status.resolved = source.resolved == true ? true : false;
    target["object"].status.icon.url = source.statusIconUrl != EMPTY_STRING ? source.statusIconUrl : null;
    target["object"].status.icon.title = source.statusIconTitle != EMPTY_STRING ? source.statusIconTitle : null;
    target["object"].status.icon.link = source.statusIconLink != EMPTY_STRING ? source.statusIconLink : null;
    //target.fields.assignee = source.assigneeName != EMPTY_STRING ? {name:source.assigneeName} : null;

    return target;
}

function issueUpdateRequestToJson(IssueUpdateRequest source, json fieldMeta) returns json {

    json target = {};

    log:printDebug("Field Edit Meta : "+source.fieldName+" - "+fieldMeta["type"].toString());

    if source.opVerb.toLower() == "set" || source.opVerb.toLower() == "remove" {
        json item_update = "";
        boolean single_value = true;
        if fieldMeta["type"].toString() == "array" {
            single_value = false;
        }
                  
        if fieldMeta.system.toString() == "components" || fieldMeta.system.toString() == "priority"  
                || fieldMeta["type"].toString() == "user"  {
            item_update = {"name": source.fieldValue};
        } else if  fieldMeta["type"].toString() == "option" {
            item_update = {"value": source.fieldValue};
        } else {
            item_update = source.fieldValue;
        }
        
        json todo; 
        if single_value {
            todo = [{source.opVerb.toLower(): item_update}];
        } else {
            todo = [{source.opVerb.toLower(): [item_update]}];
        }
        target.update = <json>{source.fieldName: todo};

    } else if source.opVerb.toLower() == "add" {
        json todo = [{source.opVerb.toLower(): source.fieldValue}];
        target.update = <json>{source.fieldName: todo};
    }
    return target;
}

function extractInternalFieldName(string field_name, json trans_meta) returns string {
    foreach string fn in trans_meta.fields.getKeys() {
        log:printDebug("TransJson:" + fn + " "+trans_meta.fields[fn].name.toString());
        if trans_meta.fields[fn].name.toString() == field_name {
            return fn; 
        }
    }
    return field_name;
}

function issueUpdateRequestTransitionToJson(IssueTransRequest source, json trans_meta) returns json {

    json target = {"transition": {"id": source.transitionName}};
   
    foreach IssueUpdateRequest fieldChange in source.fields {
        log:printDebug("Meta:"+trans_meta.toString());
        string realFieldName = extractInternalFieldName(fieldChange.fieldName, trans_meta);

        target.fields[realFieldName] = {"id": fieldChange.fieldValue};            
    }

    return target;
}
