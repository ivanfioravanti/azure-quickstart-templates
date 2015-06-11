# Install Mongo DB on a set of Ubuntu Virtual Machines using Custom Script Linux Extension and MongoDB MMS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fivanfioravanti%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-on-ubuntu-with-mms%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys Mongo DB on a set of Ubuntu Virtual Machines and then use MongoDB MMS in order to deploy any kind of MongoDB architecture on these VMs. This template also deploys a Storage Account, Virtual Network, Public IP addresses and a Network Interface.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machine  |
| vmDnsName  | Unique DNS prefix used to access the Virtual Machines. |
| numberOfInstances | Number of VMs to be created. |
| availabilitySetName | Availability set name |
| imagePublisher | Image Publisher for the OS disk, eg., Canonical |
| imageOffer | Image Offer for the OS disk eg., UbuntuServer |
| imageSKU | Image SKU for the OS disk  eg., 14.10-DAILY|
| location | location where the resources will be deployed |
| virtualNetworkName | Name of Virtual Network |
| vmSize | Size of the Virtual Machine |
| vmName | Name of Virtual Machine |
| publicIPAddressName | Name of Public IP Address Name |
| nicName | Name of Network Interface |
| mmsGroupId | MongoDB MMS Group Id |
| mmsApiKey | MongoDB MMS Api Key |
| dataFolder | Folder used to store MongoDB Data |
