## Zendesk to JSM Trigger Setting
### Create Action:
- From the **Triggers** page, click **Create trigger**.
- Put **Send Create action to JSM** into **Trigger name**, description is optional.
- Under **Meet ALL the following conditions:**, add two conditions as specified below:
    - Status Is not Solved
    - Ticket Is Created
- Under **Actions**, select **Notify by** and **Active webhook**, and pick the webhook you added earlier for the integration.
- Paste the following into the **JSON body** field:
```
{
    "action": "create",
    "ticketId": "{{ticket.id}}",
    "status": "{{ticket.status}}",
    "via": "{{ticket.via}}",
    "title": "{{ticket.title}}",
    "external_id": "{{ticket.external_id}}",
    "link": "{{ticket.link}}",
    "priority": "{{ticket.priority}}",
    "due_date": "{{ticket.due_date}}",
    "ticket_type": "{{ticket.ticket_type}}",
    "assignee_name": "{{ticket.assignee.name}}",
    "organization_name": "{{ticket.organization.name}}",
    "group_name": "{{ticket.group.name}}",
    "account": "{{ticket.account}}",
    "requester_name": "{{ticket.requester.name}}",
    "description": "{{ticket.description}}",
    "latest_comment": "{{ticket.latest_comment_html}}",
    "tags": "{{ticket.tags}}"
}
```

### Resolved Action:
- From the **Triggers** page, click **Create trigger**.
- Put **Send Resolved action to JSM** into **Trigger name**, description is optional.
- Under **Meet ALL the following condition:**, add a condition as specified below:
    - Ticket:Status Is Solved
- Under **Actions**, select **Notify by** and **Active webhook**, and pick the webhook you added earlier for the integration.
- Paste the following into the **JSON body** field:
```
{
    "action": "close",
    "ticketId": "{{ticket.id}}",
    "status": "{{ticket.status}}",
    "latest_comment": "{{ticket.latest_comment_html}}",
    "tags": "{{ticket.tags}}",
    "external_id": "{{ticket.external_id}}"
}
```

### Add Note Action:
- From the **Triggers** page, click **Create trigger**.
- Put **Send Add Note action to JSM** into **Trigger name**, description is optional.
- Under **Meet ALL the following conditions:**, add two conditions as specified below:
    - Ticket: Is Updated
    - Ticket:Status Is Not Solved
    - Ticket:Comment Is Public
- Under **Actions**, select **Notify by** and **Active webhook**, and pick the webhook you added earlier for the integration.
- Paste the following into the **JSON body** field:
```
{
    "action": "addnote",
    "ticketId": "{{ticket.id}}",
    "status": "{{ticket.status}}",
    "latest_comment": "{{ticket.latest_comment_html}}",
    "tags": "{{ticket.tags}}",
    "external_id": "{{ticket.external_id}}"
}
```