# Jira Service Management Logstash Plugin

1. Download the [Logstash plugin](https://github.com/elastic/logstash).<br/>
   The plugin is entirely free and open-source. It's under the Apache 2.0 license, so you can use it in the way that
   best suits your needs.

2. Install and run the Jira Service Management output plugin in Logstash:
* For Logstash 5.4+ <br/>
  `bin/logstash-plugin install logstash-output-jsm`
* For other versions <br/>
  `bin/plugin install logstash-output-jsm`

3. Add a Logstash integration in Jira Service Management and copy the API key. <br/>
   :warning: If the feature isn’t available on your site, keep checking Jira Service Management for updates.

4. Use plugins such as [Mutate](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html) to populate the fields that [logstash-output-jsm](https://github.com/atlassian/jsm-integration-scripts/) will use.

``` ruby
filter {
    mutate {
       add_field => {
          "jsmAction" => "create"
          "alias" => "neo123"
          "description" => "Every alert needs a description"
          "actions" => ["Restart", "AnExampleAction"]
          "tags" => ["OverwriteQuietHours","Critical"]
          "[details][prop1]" => "val1"
          "[details][prop2]" => "val2"
          "entity" => "An example entity"
          "priority" => "P4"
          "source" => "custom source"
          "user" => "custom user"
          "note" => "alert is created"
       }
    }
    ruby {
        code => "event.set('teams', [{'name' => 'Integration'}, {'name' => 'Platform'}])"
    }
}
```

5. Add the following to your configuration file and enter the integration API key you copied earlier into **apiKey**.
``` ruby
output {
  jsm {
    "apiKey" => "logstash_integration_api_key"
  }
}
```
   
6. Run Logstash.
