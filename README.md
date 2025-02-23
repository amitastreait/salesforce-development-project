# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## Pre-Requisites to Deploy

To deploy the code you must to enable the following settings

- Digital Experience must be enabled in the target org
- After enabling the digital experience make sure "Enable ExperienceBundle Metadata API" setting is enabled under digital experience setting
    - Setup -> Feature Settings -> Digital Experiences --> Settings

## Deploy the Code base to the target org

- Clone the github repo using `git clone `
- Open the folder using VS Code
- Connect VS code to the target org
- run `sf project deploy start --manifest manifest/package.xml --target-org salesforcedevelopmentproject --wait 10 --ignore-conflicts` command to deploy the code to target org.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
