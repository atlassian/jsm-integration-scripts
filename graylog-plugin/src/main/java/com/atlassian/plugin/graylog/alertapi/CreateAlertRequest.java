package com.atlassian.plugin.graylog.alertapi;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class CreateAlertRequest {

    @JsonProperty("message")
    private String message;

    @JsonProperty("teams")
    private List<TeamRecipient> teams;

    @JsonProperty("tags")
    private List<String> tags;

    @JsonProperty("description")
    private String description;

    @JsonProperty("details")
    private Map<String, String> details;

    @JsonProperty("priority")
    private String priority;

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<TeamRecipient> getTeams() {
        return teams;
    }

    public void setTeams(List<TeamRecipient> teams) {
        this.teams = teams;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Map<String, String> getDetails() {
        return details;
    }

    public void setDetails(Map<String, String> details) {
        this.details = details;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public static class TeamRecipient {

        @JsonProperty("name")
        private String name;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }
}
