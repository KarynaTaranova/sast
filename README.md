# SASTY 
*Combination of tools for SAST Scanning*

![](https://dockerbuildbadges.quelltext.eu/status.svg?organization=getcarrier&repository=sast)

### Quick and easy start
These simple steps will run blind SAST scan against your code and generate html and xml report with some low hanging fruits
Currently we have:
- python
- ruby

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
  project_name: $project_name # the name of the project used in reports
  environment: $environment   # literal name of environment (e.g. prod/stage/etc.)
  # Reporting configuration section (all report types are optional)
  html_report: true           # do you need an html report (true/false)
  junit_report: true          # do you need an xml report (true/false)
  langugage: ruby             # the language of application to be scanned  
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
