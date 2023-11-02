package com.atlassian.plugin.graylog;

import org.graylog2.plugin.PluginMetaData;
import org.graylog2.plugin.ServerStatus;
import org.graylog2.plugin.Version;

import java.net.URI;
import java.util.Collections;
import java.util.Set;

public class JsmAlarmCallbackMetaData implements PluginMetaData {
    @Override
    public String getUniqueId() {
        return JsmAlarmCallback.class.getCanonicalName();
    }

    @Override
    public String getName() {
        return "Jira Service Management Alarm Callback";
    }

    @Override
    public String getAuthor() {
        return "Atlassian";
    }

    @Override
    public URI getURL() {
        return URI.create("https://www.atlassian.com/");
    }

    @Override
    public Version getVersion() {
        return new Version(1, 3, 15, "RELEASE");
    }

    @Override
    public String getDescription() {
        return "Graylog Jira Service Management Integration plugin";
    }

    @Override
    public Version getRequiredVersion() {
        return new Version(2, 3, 2);
    }

    @Override
    public Set<ServerStatus.Capability> getRequiredCapabilities() {
        return Collections.emptySet();
    }
}
