
# Record to hold info for creating an issue link. In Jira title and then the summary is displayed. It is
# crossed out if the status resolved is true. If 'relationship' is not stated then remote link is used. 
# Mandatory fields below are marked with *.
# + issueKey - * id (KEY-XXX) of issue that this link will be assoc with
# + globalId -  id
# + url - Url of remote link *
# + title - Title of the remote link *
# + summary - Summary of the link *
# + applicationType - application type 
# + applicationName - name of application linking to
# + relationship - eg 'causes'. If not stated then remote link is assumed
# + iconUrl - url of the icon to be displayed on Jira screen for link
# + iconTitle - title of icon for this link
# + resolved - Is this linked issue resolved or not (true/false). Default to false.
# + statusIconUrl - url of the icon to be used to display the status
# + statusIconTitle - title of the icon to be used to display the status
# + statusIconLink - Link to the closed issue
public type IssueLinkRequest record {
    string issueKey = "";
    string globalId = "";
    string url = "";
    string title = "";
    string summary = "";
    string applicationType = "";
    string applicationName = "";
    string relationship = "";
    string iconUrl = "";
    string iconTitle = "";
    boolean resolved = false;
    string statusIconUrl = "";
    string statusIconTitle = "";
    string statusIconLink = "";
    !...
};

# Represents record of updating a jira issue
# + issueKey - key of the issue to be updated ie XXX-123
# + opVerb - SET, REMOVE, ADD
# + fieldName - Name of the field
# + fieldValue - Value to update the field to
public type IssueUpdateRequest record {
    string issueKey = "";
    string opVerb = "";
    string fieldName = "";
    string fieldValue = ""; 
    !...
};

# Represents record of transitioning a jira issue
# + issueKey - key of the issue to be updated ie XXX-123
# + transitionName - text name fo transition
# + fields - fields to be updated when transition is done
public type IssueTransRequest record {
    string issueKey;
    string transitionName;
    IssueUpdateRequest[] fields;
    !...
};
