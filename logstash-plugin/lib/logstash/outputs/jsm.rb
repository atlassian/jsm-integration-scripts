# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'json'
require "uri"
require "net/http"
require "net/https"

# The Jira Service Management output is used to Create, Close, Acknowledge Alerts and Add Note to alerts in Jira Service Management.
# For this output to work, your event must contain "jsmAction" field and you must configure apiKey field in configuration.
# If jsmAction is "create", event must contain "message" field.
# For other actions ("close", "acknowledge" or "note"), event must contain "alias" or "alertId" field.
#
# If your event have the following fields (If you use default field names).
#
# Example event:
#
# {
#    "note" => "test note",
#    "jsmAction" => "create",
#    "teams" => ["teams"],
#    "description" => "test description",
#    "source" => "test source",
#    "message" => "test message",
#    "priority" => "P4",
#    "tags" => ["tags"],
#    "@timestamp" => 2017-09-15T13:32:00.747Z,
#    "@version" => "1",
#    "host" => "Neo's-MacBook-Pro.local",
#    "alias" => "test-alias",
#    "details" => {
#    "prop2" => "val2",
#    "prop1" => "val1"
# },
#    "actions" => ["actions"],
#    "user" => "test user",
#    "entity" => "test entity"
# }
#
# An alert with following properties will be created.
#
#     {
#       "message": "test message",
#       "alias": "test alias",
#       "teams": ["teams"],
#       "description": "test description",
#       "source": "test source",
#       "note": "test note",
#       "user": "test user",
#       "priority": "P4",
#       "tags": [
#         "tags"
#       ],
#       "details": {
#         "prop2": "val2",
#         "prop1": "val1"
#       },
#       "actions": [
#         "actions"
#       ],
#       "entity": "test entity",
#     }
#
# Fields with prefix "Attribute" are the keys of the fields will be extracted from Logstash event.

class LogStash::Outputs::Jsm < LogStash::Outputs::Base

  config_name "jsm"

  # Jira Service Management Logstash Integration API Key
  config :apiKey, :validate => :string, :required => true

  # Proxy settings
  config :proxy_address, :validate => :string, :required => false
  config :proxy_port, :validate => :number, :required => false


  # Host of Jira Service Management api, normally you should not need to change this field.
  config :jsmBaseUrl, :validate => :string, :required => false, :default => 'https://api.atlassian.com/jsm/ops/integration/v2/alerts/'

  # Url will be used to close alerts in Jira Service Management
  config :closeActionPath, :validate => :string, :required => false, :default =>'/close'

  # Url will be used to acknowledge alerts in Jira Service Management
  config :acknowledgeActionPath, :validate => :string, :required => false, :default =>'/acknowledge'

  # Url will be used to add notes to alerts in Jira Service Management
  config :noteActionPath, :validate => :string, :required => false, :default =>'/notes'

  # The value of this field holds the name of the action will be executed in Jira Service Management.
  # This field must be in Event object. Should be one of "create", "close", "acknowledge" or "note". Other values will be discarded.
  config :actionAttribute, :validate => :string, :required => false, :default => 'jsmAction'

  # This value specifies the query parameter identifierType
  config :identifierType, :validate => :string, :required => false, :default =>'id'

  # This value will be set to eventual identifier according to event(id/alias).
  config :identifier, :validate => :string, :required => false, :default =>''

  # The value of this field holds the Id of the alert that actions will be executed.
  # One of "alertId" or "alias" field must be in Event object, except from "create" action
  config :alertIdAttribute, :validate => :string, :required => false, :default => 'alertId'

  # The value of this field holds the alias of the alert that actions will be executed.
  # One of "alertId" or "alias" field must be in Event object, except from "create" action
  config :aliasAttribute, :validate => :string, :required => false, :default => 'alias'

  # The value of this field holds the alert text.
  config :messageAttribute, :validate => :string, :required => false, :default => 'message'

  # The value of this field holds the list of team names which will be responsible for the alert.
  config :teamsAttribute, :validate => :string, :required => false, :default => 'teams'

  # The value of this field holds the Teams and users that the alert will become
  # visible to without sending any notification.
  config :visibleToAttribute, :validate => :string, :required => false, :default => 'visibleTo'

  # The value of this field holds the detailed description of the alert.
  config :descriptionAttribute, :validate => :string, :required => false, :default => 'description'

  # The value of this field holds the comma separated list of actions that can be executed on the alert.
  config :actionsAttribute, :validate => :string, :required => false, :default => 'actions'

  # The value of this field holds the source of alert. By default, it will be assigned to IP address of incoming request.
  config :sourceAttribute, :validate => :string, :required => false, :default => 'source'

  # The value of this field holds the priority level of the alert
  config :priorityAttribute, :validate => :string, :required => false, :default => 'priority'

  # The value of this field holds the comma separated list of labels attached to the alert.
  config :tagsAttribute, :validate => :string, :required => false, :default => 'tags'

  # The value of this field holds the set of user defined properties. This will be specified as a nested JSON map
  config :detailsAttribute, :validate => :string, :required => false, :default => 'details'

  # The value of this field holds the entity the alert is related to.
  config :entityAttribute, :validate => :string, :required => false, :default => 'entity'

  # The value of this field holds the default owner of the execution. If user is not specified, owner of account will be used.
  config :userAttribute, :validate => :string, :required => false, :default => 'user'

  # The value of this field holds the additional alert note.
  config :noteAttribute, :validate => :string, :required => false, :default => 'note'


  public
  def register
  end # def register

  public
  def populateAliasOrId(event, params)
    alertAlias = event.get(@aliasAttribute) if event.get(@aliasAttribute)
    if alertAlias == nil then
      alertId = event.get(@alertIdAttribute) if event.get(@alertIdAttribute)
      if !(alertId == nil) then
        @identifierType = 'id'
        @identifier = alertId
      end
    else
      @identifierType = 'alias'
      @identifier = alertAlias
    end
  end # def populateAliasOrId

  public
  def executePost(uri, params)
    unless uri == nil then
      @logger.info("Executing url #{uri}")
      url = URI(uri)
      http = Net::HTTP.new(url.host, url.port, @proxy_address, @proxy_port)
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(url.request_uri, initheader = { "Content-Type" =>"application/json", "Authorization" => "GenieKey #{@apiKey}" })
      request.body = params.to_json
      response = http.request(request)
      body = response.body
      body = JSON.parse(body)
      @logger.warn("Executed [#{uri}]. Response:[#{body}]")
    end
  end # def executePost

  public
  def receive(event)
    return unless output?(event)

    @logger.info("processing #{event}")
    jsmAction = event.get(@actionAttribute) if event.get(@actionAttribute)
    if jsmAction then
      params = {}
      populateCommonContent(params, event)

      case jsmAction.downcase
      when "create"
        uri = "#{@jsmBaseUrl}"
        params = populateCreateAlertContent(params, event)
      when "close"
        uri = "#{@jsmBaseUrl}#{@identifier}#{@closeActionPath}?identifierType=#{@identifierType}"
      when "acknowledge"
        uri = "#{@jsmBaseUrl}#{@identifier}#{@acknowledgeActionPath}?identifierType=#{@identifierType}"
      when "note"
        uri = "#{@jsmBaseUrl}#{@identifier}#{@noteActionPath}?identifierType=#{@identifierType}"
      else
        @logger.warn("Action #{jsmAction} does not match any available action, discarding..")
          return
      end

      executePost(uri, params)
    else
      @logger.warn("No jsmAction defined")
      return
    end
  end # def receive

  private
  def populateCreateAlertContent(params, event)
    params['message'] = event.get(@messageAttribute) if event.get(@messageAttribute)
    params['alias'] = event.get(@aliasAttribute) if event.get(@aliasAttribute)
    params['teams'] = event.get(@teamsAttribute) if event.get(@teamsAttribute)
    params['visibleTo'] = event.get(@visibleToAttribute) if event.get(@visibleToAttribute)
    params['description'] = event.get(@descriptionAttribute) if event.get(@descriptionAttribute)
    params['actions'] = event.get(@actionsAttribute) if event.get(@actionsAttribute)
    params['tags'] = event.get(@tagsAttribute) if event.get(@tagsAttribute)
    params['entity'] = event.get(@entityAttribute) if event.get(@entityAttribute)
    params['priority'] = event.get(@priorityAttribute) if event.get(@priorityAttribute)
    params['details'] = event.get(@detailsAttribute) if event.get(@detailsAttribute)


    return params
  end

  private
  def populateCommonContent(params, event)
    populateAliasOrId(event, params)
    params['source'] = event.get(@sourceAttribute) if event.get(@sourceAttribute)
    params['user'] = event.get(@userAttribute) if event.get(@userAttribute)
    params['note'] = event.get(@noteAttribute) if event.get(@noteAttribute)
  end

end # class LogStash::Outputs::Jsm