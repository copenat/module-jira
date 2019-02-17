@test:Config {
    dependsOn: ["test_createIssue", "test_getIssue"]
}
function test_createIssueLink() {
    log:printInfo("ACTION : createIssueLink()");

    IssueLinkRequest newIssueLink = {
        issueKey: issue_test.key,
        url: "https://www.bbc.co.uk",
        title: "BBC",
        summary: "This is a test issue link created for Ballerina Jira Connector",
        applicationName: "TESTAPP"
    };

    var output = jiraConnectorEP->createIssueLink(newIssueLink);
    if (output is JiraConnectorError) {
        test:assertFail(msg = formatJiraConnError(output));
    } else {
        string result = "";
    }
}

@test:Config {
    dependsOn: ["test_createIssueLink"]
}
function test_getIssueLink() {
    log:printInfo("ACTION : test_getIssueLink()");

    var output = jiraConnectorEP->getIssueLinks(issue_test.key);
    if (output is JiraConnectorError) {
        test:assertFail(msg = formatJiraConnError(output));
    } else {
        string result = "";
    }
}

function callUpdateIssue(IssueUpdateRequest req) {
    var output = jiraConnectorEP->updateIssue(req);
    if (output is JiraConnectorError) {
        test:assertFail(msg = formatJiraConnError(output));
    } 
}

@test:Config {
    dependsOn: ["test_createIssue", "test_getIssue"]
}
function test_updateIssue_set_desc() {
    log:printInfo("ACTION : test_updateIssue_set_desc()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "description",
        fieldValue: "this is updated from ballerina"  
    };

    callUpdateIssue(updateRequest);
}

@test:Config {
    dependsOn: ["test_updateIssue_set_desc"]
}
function test_updateIssue_set_label() {
    log:printInfo("ACTION : updateIssue_set_label()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "labels",
        fieldValue: "test_label"  
    };
    callUpdateIssue(updateRequest);
}


@test:Config {
    dependsOn: ["test_updateIssue_set_label"]
}
function test_updateIssue_set_summary() {
    log:printInfo("ACTION : test_updateIssue_set_summary()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "summary",
        fieldValue: "test summary from ballerina"  
    };
    callUpdateIssue(updateRequest);
}

@test:Config {
    dependsOn: ["test_updateIssue_set_summary"]
}
function test_updateIssue_set_assignee() {
    log:printInfo("ACTION : test_updateIssue_set_assignee()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "assignee",
        fieldValue: config:getAsString("test_username") 
    };
    callUpdateIssue(updateRequest);
}

@test:Config {
    dependsOn: ["test_updateIssue_set_assignee"]
}
function test_updateIssue_set_reporter() {
    log:printInfo("ACTION : test_updateIssue_set_reporter()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "reporter",
        fieldValue: config:getAsString("test_username") 
    };
    callUpdateIssue(updateRequest);
}

@test:Config {
    dependsOn: ["test_updateIssue_set_reporter", "test_getProjectComponent"]
}
function test_updateIssue_set_components() {
    log:printInfo("ACTION : test_updateIssue_set_components()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "components",
        fieldValue: "Test-ProjectComponent" 
    };
    callUpdateIssue(updateRequest);
}

@test:Config {
    dependsOn: ["test_updateIssue_set_components"]
}
function test_updateIssue_set_priority() {
    log:printInfo("ACTION : test_updateIssue_set_priority()");

    IssueUpdateRequest updateRequest = {
        issueKey: issue_test.key,
        opVerb: "SET",
        fieldName: "priority",
        fieldValue: "Highest" 
    };
    callUpdateIssue(updateRequest);
}


@test:Config {
    dependsOn: ["test_updateIssue_set_priority"]
}
function test_updateIssue_transition() {
    log:printInfo("ACTION : test_updateIssue_transition()");

    IssueUpdateRequest[] fields = [];
    IssueUpdateRequest field_resolve = {
        fieldName: "Resolution",
        fieldValue: "Declined" 
    };
    fields[0] = field_resolve;
    IssueTransRequest trans = {
        issueKey: issue_test.key,
        transitionName: "Done",
        fields: []        
    };

    var output = jiraConnectorEP->transitionIssue(trans);
    if (output is JiraConnectorError) {
        test:assertFail(msg = formatJiraConnError(output));
    }
}

@test:Config {
    dependsOn: ["test_updateIssue_transition"]
}
function test_updateIssue_transition_fail() {
    log:printInfo("ACTION : test_updateIssue_transition_fail()");
}

