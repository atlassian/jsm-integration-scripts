package com.atlassian.plugin.graylog.alertapi;

import com.fasterxml.jackson.annotation.JsonProperty;

public class CreateAlertResponse {

    @JsonProperty("result")
    private String result;

    @JsonProperty("requestId")
    private String requestId;

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }
}
