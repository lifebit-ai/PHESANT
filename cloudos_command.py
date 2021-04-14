#!/usr/bin/python

### Imports and globals

import requests
import json
import sys
import argparse

parser = argparse.ArgumentParser(description='This script is used to run API command to launch PHESANT (Biobank scanner) pipeline CloudOS job with example parameters.')

# Change apikey with the apikey retrieved from CloudOS' webpage
parser.add_argument("-H", "--apikey", help="Personal CloudOS API key, required. You can find API key on CloudOS workspace or personal settings page, at 'Lifebit API' tab.", required=True)

# Set id of workspace to run the command in
parser.add_argument("-w", "--workspace_id", default="", help="CloudOS workspace id, optional. If not specified - personal workspace will be used. You can find workspace id the workspace settings page on CloudOS.")

# This is the url for CloudOS service. Do not change it!
parser.add_argument("-u", "--url", default="https://cloudos.lifebit.ai", help="CloudOS url. Default: 'https://cloudos.lifebit.ai'.")

# Project name
parser.add_argument("-p", "--project_name", default="API jobs", help="Workspace Project name. Default: 'API jobs'.")

# Workflow name
parser.add_argument("--workflow_name", "--workflow", default="Biobank scanner", help="Workflow name. Change if in a custom workspace the name of workflow is different. Default: 'Biobank scanner'.")


args = parser.parse_args()
print(args)

apikey          = args.apikey
workspace_id    = args.workspace_id
url             = args.url
project_name    = args.project_name
workflow_name   = args.workflow_name

# If workspace is specified, then cloudos url will have to be followed by
# '?teamID=...' option to access data from a particular workspace
if workspace_id:
    urlopt = "?teamId=" + workspace_id
else:
    urlopt=""


### Fetch project id

# This function will fetch the project id for a given project name
def fetch_cloudos_project_id(apikey, project_name, url, urlopt):
    data = {"apikey": apikey}
    r = requests.get("{url}/api/v1/projects{opt}".format(url=url, opt=urlopt), params=data)
    for project in json.loads(r.content):
        if project["name"] == project_name:
            return project["_id"]


project_id = fetch_cloudos_project_id(apikey, project_name, url, urlopt)
if not project_id:
    sys.exit("Project id couldn't be find. Check that you provided a valid project name")
else:
    print("Project '" + project_name + "': " + project_id)
### Fetch workflow id

# This function will fetch the workflow id for a given workflow name
def fetch_cloudos_workflow_id(apikey, workflow_name, url, urlopt):
    data = {"apikey": apikey}
    r = requests.get("{url}/api/v1/workflows{opt}".format(url=url, opt=urlopt), params=data)
    for workflow in json.loads(r.content):
        if workflow["name"] == workflow_name:
            return workflow["_id"]

workflow_id = fetch_cloudos_workflow_id(apikey, workflow_name, url, urlopt)
if not workflow_id:
    sys.exit("workflow id couldn't be found. Check that you provided a valid workflow name")
else:
    print("Workflow '" + workflow_name + "': " + workflow_id)


### Running the job and checking it's status

def send_job_request_to_cloudos(apikey, workflow_id, project_id, url, urlopt):
    # Prepare api request for CloudOS to run a job
    headers = {
        "Content-type": "application/json",
        "apikey": apikey
    }

    workflow_params = [
        {
            "prefix":"--",
            "name":"pheno",
            "dataItemEmbedded":{
                "type":"S3File",
                "data":{
                    "name":"phenotypes.csv",
                    "s3BucketName":"lifebit-featured-datasets",
                    "s3ObjectKey":"pipelines/phesant-data/phenotypes.csv"
                }
            }
        },
        {
            "prefix":"--",
            "name":"traitfile",
            "dataItemEmbedded":{
                "type":"S3File",
                "data":{
                    "name":"exposure.csv",
                    "s3BucketName":"lifebit-featured-datasets",
                    "s3ObjectKey":"pipelines/phesant-data/exposure.csv"
                }
            }
        },
        {
            "prefix":"--",
            "name":"variablelist",
            "dataItemEmbedded":{
                "type":"S3File",
                "data":{
                    "name":"outcome-info.tsv",
                    "s3BucketName":"lifebit-featured-datasets",
                    "s3ObjectKey":"pipelines/phesant-data/outcome-info.tsv"
                }
            }
        },
        {
            "prefix":"--",
            "name":"datacoding",
            "dataItemEmbedded":{
                "type":"S3File",
                "data":{
                    "name":"data-coding-ordinal-info.txt",
                    "s3BucketName":"lifebit-featured-datasets",
                    "s3ObjectKey":"pipelines/phesant-data/data-coding-ordinal-info.txt"
                }
            }
        },
        {
            "prefix":"--",
            "name":"traitcol",
            "parameterKind":"textValue",
            "textValue": "exposure"
        },
        {
            "prefix":"--",
            "name":"userId",
            "parameterKind":"textValue",
            "textValue": "userId"
        }
    ]

    params = {
        "parameters": workflow_params,
        "project": project_id,
        "workflow": workflow_id,
        "name": workflow_name + " API",
        "executionPlatform": "aws",
        "execution": {
        "computeCostLimit":-1,
        "optim":"test"
        },
        "instanceType": "m2.2xlarge",
        "masterInstance": {
            "requestedInstance": {
            "type":"m2.2xlarge"
            }
        }
    }

    r = requests.post("{url}/api/v1/jobs{opt}".format(url=url, opt=urlopt), data=json.dumps(params), headers=headers)
    return json.loads(r.content)["_id"]

job_id = send_job_request_to_cloudos(apikey, workflow_id, project_id, url, urlopt)
if job_id:
    print("Job successfully sent to CloudOS. You can check the status " +
          "of the job in https://cloudos.lifebit.ai/app/jobs/{}".format(job_id))
