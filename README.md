# SASTY 
*Combination of tools for SAST Scanning*

[![](https://dockerbuildbadges.quelltext.eu/status.svg?organization=getcarrier&repository=sast)](https://hub.docker.com/r/getcarrier/sast/builds/)

### Quick and easy start
These simple steps will run blind SAST scan against your code and generate html and xml report with some low hanging fruits
Currently we have:
- python
- java
- nodejs
- ruby
- scala

##### 1. Install docker
 
##### 2. Start container and pass 5 config options to container and mount reports folder:

`project_name` - the name of your project will be displayed in reports

`environment` - name of brunch or any other identified to be used in reports

`path_to_your_code` - path do the code on your local machine

`your_local_path_to_reports` - path on your local filesystem where you want to store reports from this execution

For example:

``` 
docker run -t \
       -e project_name=MY_PET_PROJECT -e environment=master \
       -v <your_local_path_to_reports>:/tmp/reports \
       -v <path_to_your_code>:/code \
       --name=dusty --rm \
       getcarrier/sast:latest -s sast
```

##### 3. Open scan report
Report is located in your `your_local_path_to_reports` folder

### Configuration
Scans can be configured using `scan-config.yaml` file.

##### scan-config.yaml structure
```
sast # Name of the scan
  # General configuration section
  target_host: $host          # host to scan (e.g. my.domain.com)
  target_port: $port          # port where it is hosted (e.g. 443)
  protocol: $protocol         # http or https
  project_name: $project_name # the name of the project used in reports
  environment: $environment   # literal name of environment (e.g. prod/stage/etc.)
  langugage: python             # the language of application to be scanned
  
  # Reporting configuration section (all report types are optional)
  html_report: true           # do you need an html report (true/false)
  junit_report: true          # do you need an xml report (true/false)
  reportportal:               # ReportPortal.io specific section
    rp_host: https://rp.com   # url to ReportPortal.io deployment 
    rp_token: XXXXXXXXXXXXX   # ReportPortal authentication token
    rp_project_name: XXXXXX   # Name of a Project in ReportPortal to send results to
    rp_launch_name: XXXXXXX   # Name of a Launch in ReportPortal to send results to
  jira:
    url: https://jira.com     # Url to Jira
    username: some.dude       # User to create tickets
    password: password        # password to user in Jira
    jira_project: XYZC        # Jira project ID
    assignee: some.dude       # Jira id of default assignee
    issue_type: Bug           # Jira issue type (Default: Bug)
    labels: some,label        # Comaseparated list of lables for ticket
    watchers: another.dude    # Comaseparated list of Jira IDs for watchers
    jira_epic_key: XYZC-123   # Jira epic key (or id)
    min_priority: Major       # Min priority level to create jira ticket.
                              # default - Major
  emails:
    smtp_server: smtp.office.com    # smtp server address
    port: 587                       # smtp server port
    login: some_userexample.com     # smtp user autentification
    password: password              # smtp user password
    receivers_email_list:           # string with receivers list, separated ', '
      'user1@epam.com, user2epam.com' 
    subject: some text              # email subject
    body: some text                 # email body (text or html)
    attach_html_report: True        # add report to attachments
    attachments: '1.txt, 2.pdf'     # mounted to /attachments folder (optional)
                                    # string attachments file names, separated ', '
    open_states: XYZ                # string with open states list of issues,
                                    # that will be shown in the email,
                                    # separated ', '. default [Open, In Progress]
  ptai:
    # name of html report that to create jira tickets from
    report_name: NAME_OF_REPORT
  # NodeJs composition analysis tool
  npm:
    devdep: true
  # NodeJs composition analysis tool
  retirejs:
    devdep: true
  # Python composition analysis tool
  safety:
    files: ['requirements.txt'] # relative file paths to scan, 
                                # started from mounted code folder
```
configuration can be mounted to container like 
```
-v <path_to_local_folder>/scan-config.yaml:/tmp/scan-config.yaml
```

##### False positive filtering configuration
User need to fill `false_positive.config` file with titles of false-positive issues and mount it to container
```
-v <path_to_local_folder>/false_positive.config:/tmp/false_positive.config
```

##### Please note that `scan-config.yaml` and `false_positive.config` included for demo purposes

### Creating jira tickets from PT AI html report

Please mount folder, that contains PT AI html report, to /tmp/reports docker volume.

#### scan-config.yaml example
```
ptai # Name of the scan
  jira:
    url: https://jira.com     # Url to Jira
    username: some.dude       # User to create tickets
    password: password        # password to user in Jira
    jira_project: XYZC        # Jira project ID
    assignee: some.dude       # Jira id of default assignee
    issue_type: Bug           # Jira issue type (Default: Bug)
    labels: some,label        # Comaseparated list of lables for ticket
    watchers: another.dude    # Comaseparated list of Jira IDs for watchers
    jira_epic_key: XYZC-123   # Jira epic key (or id) 
  ptai:
    # name of html report that to create jira tickets from
    report_name: NAME_OF_REPORT
