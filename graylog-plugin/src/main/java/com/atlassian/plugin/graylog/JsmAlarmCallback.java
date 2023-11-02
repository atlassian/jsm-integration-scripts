package com.atlassian.plugin.graylog;

import com.google.common.collect.Maps;
import org.apache.commons.lang.StringUtils;
import org.graylog2.plugin.alarms.AlertCondition;
import org.graylog2.plugin.alarms.callbacks.AlarmCallback;
import org.graylog2.plugin.alarms.callbacks.AlarmCallbackConfigurationException;
import org.graylog2.plugin.alarms.callbacks.AlarmCallbackException;
import org.graylog2.plugin.configuration.Configuration;
import org.graylog2.plugin.configuration.ConfigurationException;
import org.graylog2.plugin.configuration.ConfigurationRequest;
import org.graylog2.plugin.configuration.fields.ConfigurationField;
import org.graylog2.plugin.configuration.fields.DropdownField;
import org.graylog2.plugin.configuration.fields.TextField;
import org.graylog2.plugin.streams.Stream;

import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


public class JsmAlarmCallback implements AlarmCallback {
    private static final String API_KEY = "api_key";
    private static final String TEAMS = "teams";
    private static final String TAGS = "tags";
    private static final String PRIORITY = "priority";
    private static final String PROXY = "proxy_address";
    private static final String API_URL = "api_url";
    private static final String SHOW_FIELDS = "show_fields";

    private Configuration configuration;

    @Override
    public void initialize(Configuration configuration) throws AlarmCallbackConfigurationException {
        this.configuration = configuration;
    }

    @Override
    public void call(Stream stream, AlertCondition.CheckResult checkResult) throws AlarmCallbackException {
        call(new JsmGraylogClient(configuration.getString(API_KEY), configuration.getString(TAGS),
                configuration.getString(TEAMS), configuration.getString(PRIORITY), configuration.getString(API_URL), configuration.getString(SHOW_FIELDS), configuration.getString(PROXY)), stream, checkResult);
    }

    private void call(JsmGraylogClient jsmGraylogClient, Stream stream, AlertCondition.CheckResult checkResult) throws AlarmCallbackException {
        jsmGraylogClient.trigger(stream, checkResult);
    }


    @Override
    public ConfigurationRequest getRequestedConfiguration() {
        final ConfigurationRequest configurationRequest = new ConfigurationRequest();

        configurationRequest.addField(new TextField(API_KEY,
                "JSM API key", "",
                "JSM API integration key",
                ConfigurationField.Optional.NOT_OPTIONAL));

        configurationRequest.addField(new TextField(PROXY,
                "Proxy",
                null,
                "Please insert the proxy information in the following format: <ProxyAddress>:<Port>",
                ConfigurationField.Optional.OPTIONAL));

        configurationRequest.addField(new TextField(TAGS,
                "Tags", "",
                "Comma separated list of alert tags",
                ConfigurationField.Optional.OPTIONAL));

        configurationRequest.addField(new TextField(TEAMS,
                "Teams", "",
                "Comma separated list of team names",
                ConfigurationField.Optional.OPTIONAL));

        configurationRequest.addField(new TextField(API_URL,
                "JSM API URL", "",
                "JSM API integration URL",
                ConfigurationField.Optional.NOT_OPTIONAL));

        configurationRequest.addField(new TextField(SHOW_FIELDS,
                "Show fields", "",
                "Comma separated list of displayed fields, default show all",
                ConfigurationField.Optional.OPTIONAL));


        HashMap<String, String> priorities = new HashMap<>();
        priorities.put("P1", "P1-Critical");
        priorities.put("P2", "P2-High");
        priorities.put("P3", "P3-Moderate");
        priorities.put("P4", "P4-Low");
        priorities.put("P5", "P5-Informational");
        configurationRequest.addField(new DropdownField(PRIORITY,
                "Priority",
                "P3", priorities,
                "Priority level of the alert. Default is P3-Moderate",
                ConfigurationField.Optional.OPTIONAL));

        return configurationRequest;
    }

    @Override
    public String getName() {
        return "Jira Service Management alarm callback";
    }

    @Override
    public Map<String, Object> getAttributes() {
        Map<String, Object> source = configuration.getSource();

        if (source != null) {
            return Maps.transformEntries(source, (key, value) -> {
                if (API_KEY.equals(key)) {
                    return "****";
                }

                return value;
            });
        }

        return new HashMap<>();
    }

    @Override
    public void checkConfiguration() throws ConfigurationException {
        if (!configuration.stringIsSet(API_KEY)) {
            throw new ConfigurationException(API_KEY + " is mandatory and must be not be null or empty.");
        }

        if (configuration.stringIsSet(PROXY)) {
            String urlString = configuration.getString(PROXY);

            if (StringUtils.startsWith(urlString, "http")) {
                throw new ConfigurationException("Couldn't parse " + PROXY + ", please remove scheme (http/https)");
            }

            if (StringUtils.countMatches(urlString, ":") != 1) {
                throw new ConfigurationException("Couldn't parse " + PROXY + ", please make sure ':' appears only once");
            }

            String[] urlPortPair = StringUtils.split(urlString, ":");

            if (urlPortPair != null) {
                if (urlPortPair.length < 2) {
                    throw new ConfigurationException("Couldn't parse " + PROXY + ", please review the proxy information");
                } else {
                    List<String> urlPortPairList = Arrays.stream(urlPortPair).filter(StringUtils::isNotBlank).collect(Collectors.toList());

                    if (urlPortPairList.size() == 2) {
                        String portString = urlPortPair[1];
                        int port;

                        try {
                            port = Integer.parseInt(portString);
                        } catch (NumberFormatException e) {
                            throw new ConfigurationException("Could not parse " + PROXY + ", please make sure port is a number");
                        }

                        InetSocketAddress sockAddress = new InetSocketAddress(urlPortPair[0], port);

                        if (sockAddress.isUnresolved()) {
                            throw new ConfigurationException("Couldn't resolve " + PROXY);
                        }
                    } else {
                        throw new ConfigurationException("Couldn't parse " + PROXY + ", please review the proxy information");
                    }
                }
            }
        }
    }
}
