# Graylog integration plugin for Jira Service Management

Jira Service Management offers an integration plugin for Graylog. Graylog can use this plugin to send stream alerts to Jira Service Management with detailed information. Jira Service Management acts as a dispatcher for Graylog alerts, determining the right people to notify based on their on-call schedules via email, text messages (SMS), phone calls, and push notifications (both iPhone & Android), and by escalating alerts until they're acknowledged or closed.

:warning: _If the feature isn't available on your site, keep checking Jira Service Management for updates._

**Requirements**

This project uses Maven 3 and requires Java 7 or higher. The plugin requires Graylog 1.0.0 or higher.

**Steps to build the plugin**

1. Clone this repository.
2. Run mvn package to build a JAR file.
3. Optional: Run mvn jdeb:jdeb and mvn rpm:rpm to create a DEB and RPM package respectively.
4. Copy the generated JAR file into a target directory within the Graylog plugin directory.
5. Restart Graylog.