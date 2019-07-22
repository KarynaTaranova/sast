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
By default scan-config.yaml is in `/tmp` folder.
```
-v <path_to_local_folder>/scan-config.yaml:/tmp/scan-config.yaml
```
It is possible to specify path to config using `config_path` environment variable.
```
-e config_path=/example_folder/example_config.yaml
-v <path_to_local_folder>/scan-config.yaml:/example_folder/example_config.yaml
```

##### scan-config.yaml structure
```
sast: # Name of the scan
  # General configuration section
  code_path: $code_path       # path to folder with code to scan. Default - /code
  target_host: $host          # host to scan (e.g. my.domain.com)
  target_port: $port          # port where it is hosted (e.g. 443)
  protocol: $protocol         # http or https
  project_name: $project_name # the name of the project used in reports
  environment: $environment   # literal name of environment (e.g. prod/stage/etc.)
  min_priority: Major         # Min priority level to process vulnerability.
                              # default - Major
                              # possible: Trivial, Minor, Major, Critical, Blocker
  language: python             # the language of application to be scanned
  
  # Reporting configuration section (all report types are optional)
  html_report: true           # do you need an html report (true/false)
  junit_report: true          # do you need an xml report (true/false)
  reportportal:               # ReportPortal.io specific section
    rp_host: https://rp.com   # url to ReportPortal.io deployment 
    rp_token: XXXXXXXXXXXXX   # ReportPortal authentication token
    rp_project_name: XXXXXX   # Name of a Project in ReportPortal to send results to
    rp_launch_name: XXXXXXX   # Name of a Launch in ReportPortal to send results to
  jira:
    url: https://jira.com          # Url to Jira
    username: some.dude            # User to create tickets
    password: password             # password to user in Jira
    project: XYZC                  # Jira project ID
    fields:
      assignee: some.dude          # Jira id of default assignee
      issue_type: Bug              # Jira issue type (Default: Bug)
      epic_link: XYZC-123          # Jira epic key (or id)
      labels: some,label           # Comaseparated list of lables for ticket
      watchers: 
        'some.dude, another.dude'  # Comaseparated list of Jira IDs for watchers      
      Story Points: some value     # Another custom field. Name or id can be used
  emails:
    smtp_server: smtp.office.com    # smtp server address
    port: 587                       # smtp server port
    login: some_user@example.com    # smtp user autentification
    password: password              # smtp user password
    receivers_email_list:           # string with receivers list, separated ', '
      'user1@example.com, user2@example.com' 
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
    filtered_statuses: discarded, suspected 
                                    # separated ', '. default ['discarded', 'suspected']
    
  composition_analysis: true/false  # enable/disable composition analysis
    or
  composition_analysis:
    devdep: true/fasle              # for nodejs projects (optional)
      or
    files: ['requirements.txt']     # for python projects (optional)
                                    #   relative file paths to scan, 
                                    #   started from mounted code folder
```
configuration can be mounted to container like 
```
-v <path_to_local_folder>/scan-config.yaml:/tmp/scan-config.yaml
```

##### Jira congifuration
There are some fields in a ticket that has default value:
- issuetype: Bug
- summary: `!default_summary`
- description: `!default_description`
- priority: `!default_priority`

It is possible to remove default field from ticket by using `!remove` option:
```  
jira:
  description: !remove
```
It is possible to use default values to fill other ticket fields:
```  
jira:
  labels: !default_priority
  description: Some aditional text. !default_description. !default_summary
```
Also custom fields can be added to a ticket:
```  
jira:
  Story Points: some value
```
Custom field `name` can be used as well as field `id`.

##### False positive filtering configuration
User need to fill `false_positive.config` file with hash-codes of false-positive issues and mount it to container
By default false_positive.config is in `/tmp` folder.
```
-v <path_to_local_folder>/false_positive.config:/tmp/false_positive.config
```
It is possible to specify path to config using `false_positive_path` environment variable. 
```
-e false_positive_path=/example_folder/example_false_positive.config
-v <path_to_local_folder>/false_positive.config:/example_folder/example_false_positive.config
```

##### Please note that `scan-config.yaml` and `false_positive.config` included for demo purposes

### Creating jira tickets from PT AI html report

Please mount folder, that contains PT AI html report, to /tmp/reports docker volume.

#### scan-config.yaml example
```
ptai: # Name of the scan
  jira:
    url: https://jira.com     # Url to Jira
    username: some.dude       # User to create tickets
    password: password        # password to user in Jira
    project: XYZC             # Jira project ID
    fields:
      assignee: some.dude       # Jira id of default assignee
      issue_type: Bug           # Jira issue type (Default: Bug)
      labels: some,label        # Comaseparated list of lables for ticket
      watchers: another.dude    # Comaseparated list of Jira IDs for watchers
      epic_link: XYZC-123   # Jira epic key (or id) 
  ptai:
    # name of html report that to create jira tickets from
    report_name: NAME_OF_REPORT
    filtered_statuses: discarded, suspected
```
   
#### Jira test
Use next command to create test ticket.
```
jira_check -s {test_name}
```
One test jira ticker will be created using config settings.
To delete test ticket use (use user and password to provide account that can delete tickets):
```
jira_check -s {test_name} -d TICKET_KEY -u user -p password
```
