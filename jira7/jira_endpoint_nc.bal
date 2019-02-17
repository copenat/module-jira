
# Adds a link to a Jira Issue.
# + link - the details of the comment to be added
# + return - true if the process is successful or JiraConnectorError
remote function Client.createIssueLink(IssueLinkRequest link) returns boolean|JiraConnectorError {

    http:Request linkReq = new;

    json jsonPayload = issueLinkRequestToJson(link);
    log:printDebug("Remote Link payload : " + jsonPayload.toString());
    linkReq.setJsonPayload(jsonPayload);
    string url = "/issue/" + link.issueKey +"/remotelink";
    log:printDebug("Remote Link url : " + url);

    var httpResponseOut = self.jiraClient->post(url, linkReq);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);

    if (jsonResponseOut is JiraConnectorError) {
        return jsonResponseOut;
    } else {
        return true;
    }
}

# Adds a comment to a Jira Issue.
# + key - the key of the jira issue
# + return - true if the process is successful or JiraConnectorError
remote function Client.getIssueLinks(string key) returns json|JiraConnectorError {
 
    string url = "/issue/" + key +"/remotelink";
    log:printDebug("Get remote link url : " + url);

    var httpResponseOut = self.jiraClient->get(url);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);

    // TODO: make this return a record
    return jsonResponseOut;
}


# updates a Jira Issue.
# + update - the details of the update to be requested
# + return - true if the process is successful or JiraConnectorError
remote function Client.updateIssue(IssueUpdateRequest update) returns boolean|JiraConnectorError {

    http:Request updateReq = new;
    json jsonPayload;
    string url;

    var editmetaResponse = self->getIssueEditMeta(untaint update.issueKey);
    if (editmetaResponse is JiraConnectorError) {
        return editmetaResponse;
    } else {
        if editmetaResponse.fields[update.fieldName].schema["type"].toString() == "user" {
            var user = self->getUser(untaint update.fieldValue);
            if (user is User[]) {
                update.fieldValue = user[0].name;
            }
        }
        jsonPayload = issueUpdateRequestToJson(update, editmetaResponse.fields[update.fieldName].schema);
        url = "/issue/" + update.issueKey;
        log:printDebug("Issue update : " + jsonPayload.toString());
        updateReq.setJsonPayload(untaint jsonPayload);
        log:printDebug("Issue update url : " + url);

        var httpResponseOut = self.jiraClient->put(untaint url, updateReq);
        //Evaluate http response for connection and server errors
        var jsonResponseOut = getValidatedResponse(httpResponseOut);
        if (jsonResponseOut is JiraConnectorError) {
            return jsonResponseOut;
        } else {
            return true;
        }
    }
}

# Retrieve the editmeta for a Jira Issue.
# https://docs.atlassian.com/software/jira/docs/api/REST/7.12.0/?_ga=2.231621916.2024074327.1540292973-144816989.1535551430#api/2/issue-getEditIssueMeta
# + key - the key of the issue ie XXX-123
# + return - true if the process is successful or JiraConnectorError
remote function Client.getIssueEditMeta(string key)returns json|JiraConnectorError {

    http:Request req = new;

    string url = "/issue/" + key + "/editmeta"; 
    log:printDebug("Issue editmeta url : " + url);

    var httpResponseOut = self.jiraClient->get(url);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);
    return jsonResponseOut;
}

# Get the Jira User details
# + user - values to find the user
# + return - List of user record 
remote function Client.getUser(string user) returns User[]|JiraConnectorError {

    var httpResponseOut = self.jiraClient->get("/user/search?username=" + user);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);

    if (jsonResponseOut is JiraConnectorError) {
        return jsonResponseOut;
    } else {
        // var userOut = <User[]>jsonResponseOut;
        User[]|error userOut = User[].convert(jsonResponseOut);
        if (userOut is error) {
            return errorToJiraConnectorError(userOut);
        } else {
            return userOut;
        }
    }
}

# transitions a Jira Issue.
# + transition - the details of the update to be requested
# + return - true if the process is successful or JiraConnectorError
remote function Client.transitionIssue(IssueTransRequest transition) returns boolean|JiraConnectorError {

    // TODO: 
    // 1. If the transition fail due to errors with additional fields 
    //       then try again with these field removed
    // 2. If a comment has been added then add that to transition

    http:Request updateReq = new;
    json jsonPayload;
    string url;

    json transitions;
    var em = self->getTransitions(transition.issueKey);
    if (em is JiraConnectorError) {
        return em;
    } else {
        transitions = em;
    }

    foreach json trans in <json[]>transitions.transitions {
        if trans.to.name.toString() == transition.transitionName {
            log:printDebug("Found trans to perform : "+transition.transitionName+" : "+trans.id.toString());
            transition.transitionName = trans.id.toString();
            jsonPayload = issueUpdateRequestTransitionToJson(transition, trans);
            log:printDebug("Issue update : " + jsonPayload.toString());
            updateReq.setJsonPayload(untaint jsonPayload);

            url = "/issue/" + transition.issueKey + "/transitions";
            log:printDebug("Issue update url : " + url);

            var httpResponseOut = self.jiraClient->post(untaint url, updateReq);
            //Evaluate http response for connection and server errors
            var jsonResponseOut = getValidatedResponse(httpResponseOut);
            if (jsonResponseOut is JiraConnectorError) {
                return jsonResponseOut;
            } else {
                return true;
            }
        }
    }
    JiraConnectorError e = {
        ^"type": "Http Connector Error",
        message: "Unable to find transition " + transition.transitionName
    };
    return e;
}


# Retrieve the transitions for this Jira Issue.
# https://docs.atlassian.com/software/jira/docs/api/REST/7.12.0/?_ga=2.231621916.2024074327.1540292973-144816989.1535551430#api/2/issue-getTransitions
# + key - the key of the issue ie XXX-123
# + return - true if the process is successful or JiraConnectorError
remote function Client.getTransitions(string key) returns json|JiraConnectorError {

    http:Request req = new;

    string url = "/issue/" + key + "/transitions?expand=transitions.fields"; 
    log:printDebug("Issue transitions url : " + url);

    var httpResponseOut = self.jiraClient->get(url);
    //Evaluate http response for connection and server errors
    var jsonResponseOut = getValidatedResponse(httpResponseOut);

    if (jsonResponseOut is  JiraConnectorError) {
        return jsonResponseOut;
    } else {
        log:printDebug("Transitions for "+key+" : "+jsonResponseOut.toString());
        return jsonResponseOut;
    }
}

