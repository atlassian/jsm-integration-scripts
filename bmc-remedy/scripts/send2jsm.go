package main

import (
	"bufio"
	"bytes"
	"crypto/tls"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/alexcesaro/log"
	"github.com/alexcesaro/log/golog"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

var API_KEY string = ""
var TOTAL_TIME = 60
var configParameters = map[string]string{"apiKey": API_KEY,
	"jsm.api.url":                       "https://api.atlassian.com",
	"bmcRemedy2jsm.logger":              "warning",
	"bmcRemedy2jsm.http.proxy.enabled":  "false",
	"bmcRemedy2jsm.http.proxy.port":     "1111",
	"bmcRemedy2jsm.http.proxy.host":     "localhost",
	"bmcRemedy2jsm.http.proxy.protocol": "http",
	"bmcRemedy2jsm.http.proxy.username": "",
	"bmcRemedy2jsm.http.proxy.password": ""}

var logger log.Logger

type Incident struct {
	IncidentID         string
	Company            string
	Customer           string
	ContactFirstName   string
	ContactLastName    string
	ContactCompany     string
	ContactSensitivity string
	ContactClientType  string
	Notes              string
	Template           string
	Summary            string
	Service            string
	CI                 string
	TargetDate         string
	Impact             string
	Urgency            string
	Priority           string
	IncidentType       string
	ReportedSource     string
	AssignedGroup      string
	Assignee           string
	VendorGroup        string
	VendorTicketNumber string
	Status             string
	StatusReason       string
	Resolution         string
}

func main() {
	scriptPath, err := os.Executable()
	if err != nil {
		panic(err)
	}
	loggerPath := filepath.Dir(scriptPath)
	logger = configureLogger(loggerPath)
	logger.Info("Initializing BMC Remedy to Jira Service Management Script..\r\n")

	configPathPtr := flag.String("config-path", "C:\\Jsm\\BMCRemedyIntegration\\jsm-integration\\conf\\integration.conf", "Jsm Config Path")
	configFile, err := os.Open(*configPathPtr)
	configPath2 := "C:\\jsm-integration\\conf\\jec-config.json"

	if err == nil {
		readConfigFile(configFile, configPathPtr)
	} else {
		panic(err)
	}

	errFromConf := readConfigurationFileFromJECConfig(configPath2)

	if errFromConf != nil {
		panic(errFromConf)
	}

	logger.Debug(configParameters, "\r\n")
	printConfigToLog()

	incident := parseFlags()

	webhookData, err := json.Marshal(incident)
	check(err)

	var jsonBody []byte = []byte(string(webhookData))

	http_post(jsonBody, incident.IncidentID)

}

func parseFlags() Incident {
	JsmIntegrationAPIKey := flag.String("jsm-integration-api-key", "", "Jsm Integration API Key")
	IncidentID := flag.String("incident-id", "", "Incident ID")
	Company := flag.String("company", "", "Company")
	Customer := flag.String("customer", "", "Customer")
	ContactFirstName := flag.String("contact-first-name", "", "Contact First Name")
	ContactLastName := flag.String("contact-last-name", "", "Contact Last Name")
	ContactCompany := flag.String("contact-company", "", "Contact Company")
	ContactSensitivity := flag.String("contact-sensitivity", "", "Contact Sensitivity")
	ContactClientType := flag.String("contact-client-type", "", "Contact Client Type")
	Notes := flag.String("notes", "", "Notes")
	Template := flag.String("template", "", "Template")
	Summary := flag.String("summary", "", "Summary")
	Service := flag.String("service", "", "Service")
	CI := flag.String("CI", "", "CI")
	TargetDate := flag.String("target-date", "", "Target Date")
	Impact := flag.String("impact", "", "Impact")
	Urgency := flag.String("urgency", "", "Urgency")
	Priority := flag.String("priority", "", "Urgency")
	IncidentType := flag.String("incident-type", "", "Incident Type")
	ReportedSource := flag.String("reported-source", "", "Reported Source")
	AssignedGroup := flag.String("assigned-group", "", "Assigned Group")
	Assignee := flag.String("assignee", "", "Assignee")
	VendorGroup := flag.String("vendor-group", "", "Vendor Group")
	VendorTicketNumber := flag.String("vendor-ticket-number", "", "Vendor Ticket Number")
	Status := flag.String("status", "", "Status")
	StatusReason := flag.String("status-reason", "", "Status Reason")
	Resolution := flag.String("resolution", "", "Resolution")

	flag.Parse()
	incident := Incident{*IncidentID,
		*Company, *Customer, *ContactFirstName,
		*ContactLastName, *ContactCompany,
		*ContactSensitivity, *ContactClientType,
		*Notes, *Template, *Summary, *Service,
		*CI, *TargetDate, *Impact, *Urgency,
		*Priority, *IncidentType, *ReportedSource,
		*AssignedGroup, *Assignee, *VendorGroup,
		*VendorTicketNumber, *Status, *StatusReason,
		*Resolution}
	API_KEY = *JsmIntegrationAPIKey

	logger.Info("Flags parsed successfully:\r\n")
	logger.Debug(incident, "\r\n")
	return incident
}

func getHttpClient(timeout int) *http.Client {
	seconds := (TOTAL_TIME / 12) * 2 * timeout
	var proxyEnabled = configParameters["bmcRemedy2jsm.http.proxy.enabled"]
	var proxyHost = configParameters["bmcRemedy2jsm.http.proxy.host"]
	var proxyPort = configParameters["bmcRemedy2jsm.http.proxy.port"]
	var scheme = configParameters["bmcRemedy2jsm.http.proxy.protocol"]
	var proxyUsername = configParameters["bmcRemedy2jsm.http.proxy.username"]
	var proxyPassword = configParameters["bmcRemedy2jsm.http.proxy.password"]
	proxy := http.ProxyFromEnvironment

	if proxyEnabled == "true" {

		u := new(url.URL)
		u.Scheme = scheme
		u.Host = proxyHost + ":" + proxyPort
		if len(proxyUsername) > 0 {
			u.User = url.UserPassword(proxyUsername, proxyPassword)
		}
		if logger != nil {
			logger.Debug("Formed Proxy url: ", u, "\r\n")
		}
		proxy = http.ProxyURL(u)
	}
	logger.Warning("final proxy", proxy, "\r\n")
	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			Proxy:           proxy,
			Dial: func(netw, addr string) (net.Conn, error) {
				conn, err := net.DialTimeout(netw, addr, time.Second*time.Duration(seconds))
				if err != nil {
					if logger != nil {
						logger.Error("Error occurred while connecting: ", err, "\r\n")
					}
					return nil, err
				}
				conn.SetDeadline(time.Now().Add(time.Second * time.Duration(seconds)))
				return conn, nil
			},
		},
	}
	return client
}

func http_post(jsonBody []byte, incidentID string) {
	if API_KEY == "" {
		API_KEY = configParameters["apiKey"]
	}

	apiUrl := configParameters["jsm.api.url"] + "/jsm/ops/integration/v1/json/bmcremedy?apiKey=" + API_KEY

	if logger != nil {
		logger.Debug("URL: ", apiUrl, "\r\n")
		logger.Debug("Data to be posted:\r\n")
		logger.Debug(string(jsonBody), "\r\n")
	}
	var logPrefix = "[Incident Number:" + incidentID + "]"
	var target = "Jira Service Management"

	request, _ := http.NewRequest("POST", apiUrl, bytes.NewBuffer(jsonBody))

	for i := 1; i <= 3; i++ {
		client := getHttpClient(i)

		if logger != nil {
			logger.Info(logPrefix+"Trying to send data to "+target+" with timeout: ", (TOTAL_TIME/12)*2*i, "\r\n")
		}

		resp, error := client.Do(request)
		if error == nil {
			defer resp.Body.Close()
			body, err := ioutil.ReadAll(resp.Body)
			if err == nil {
				if resp.StatusCode == 200 {
					if logger != nil {
						logger.Debug(logPrefix+"Response code: "+strconv.Itoa(resp.StatusCode), "\r\n")
						logger.Debug(logPrefix+"Response: "+string(body[:]), "\r\n")
						logger.Debug(logPrefix + "Data from BMC Remedy posted to " + target + " successfully \r\n")
					}
				} else {
					if logger != nil {
						logger.Error(logPrefix+"Couldn't post data from BMC Remedy to "+target+" successfully; Response code: "+strconv.Itoa(resp.StatusCode)+" Response Body: "+string(body[:]), "\r\n")
					}
				}
			} else {
				if logger != nil {
					logger.Error(logPrefix+"Couldn't read the response from "+target, err, "\r\n")
				}
			}
			break
		} else if i < 3 {
			if logger != nil {
				logger.Error(logPrefix+"Error occurred while sending data, will retry.", error, "\r\n")
			}
		} else {
			if logger != nil {
				logger.Error(logPrefix+"Failed to post data from BMC Remedy ", error, "\r\n")
			}
		}
		if resp != nil {
			defer resp.Body.Close()
		}
	}
}

func configureLogger(logFilePath string) log.Logger {
	logFilePath += "\\send2jsm.log"
	var tmpLogger log.Logger
	file, err := os.OpenFile(logFilePath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)

	if err != nil {
		fmt.Println("Could not create log file \""+logFilePath+" Error: ", err)
	} else {
		tmpLogger = golog.New(file, log.Info)
	}

	return tmpLogger
}

func printConfigToLog() {
	if logger != nil {

		logger.Debug("Config:\r\n")
		for k, v := range configParameters {
			if strings.Contains(k, "password") {
				logger.Debug(k, "=*******", "\r\n")
			} else {
				logger.Debug(k, "=", v, "\r\n")
			}
		}

	}
}

func readConfigFile(file io.Reader, configPathPtr *string) {
	logger.Info("Reading config file located at:", *configPathPtr, "\r\n")
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()

		line = strings.TrimSpace(line)
		if !strings.HasPrefix(line, "#") && line != "" {
			l := strings.SplitN(line, "=", 2)
			l[0] = strings.TrimSpace(l[0])
			l[1] = strings.TrimSpace(l[1])
			configParameters[l[0]] = l[1]
			logger.Info("key:", l[0], "value:", l[1])
			if l[0] == "timeout" {
				TOTAL_TIME, _ = strconv.Atoi(l[1])
			}
		}
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}
}

func readConfigurationFileFromJECConfig(filepath string) error {

	jsonFile, err := os.Open(filepath)

	if err != nil {
		return err
	}

	byteValue, _ := ioutil.ReadAll(jsonFile)

	data := Configuration{}

	err = json.Unmarshal([]byte(byteValue), &data)

	if err != nil {
		return err
	}

	if configParameters["apiKey"] == "" {
		configParameters["apiKey"] = data.ApiKey
	}
	if configParameters["jsm.api.url"] != data.BaseUrl {
		configParameters["jsm.api.url"] = data.BaseUrl
	}

	defer jsonFile.Close()
	return err

}

type Configuration struct {
	ApiKey  string `json:"apiKey"`
	BaseUrl string `json:"baseUrl"`
}

func check(err error) {
	if err != nil {
		panic(err)
		logger.Error(err, "\r\n")
	}
}
