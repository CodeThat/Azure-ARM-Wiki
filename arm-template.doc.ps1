<#
    PowerShell PSDocs Document to create an ARM Template Markdown Template.

    Requirements:
    - PSDocs PowerShell Module (Install-Module -Name PSDocs)

#>

# Description: A definition to generate markdown for an ARM template
document 'arm-template' {

    # Table of Contents
    '[[_TOC_]]'

    # Set document title
    Title $InputObject.metadata.itemDisplayName

    # Write opening line
    $InputObject.metadata.Description

    # Add each parameter to a table
    Section 'Parameters' {
        $InputObject.ARMTemplate.parameters | Table -Property @{ Name = 'Parameter name'; Expression = { $_.Name } }, Description
    }

    Section 'Variables' {
        $InputObject.ARMTemplate.Variables | Table -Property @{ Name = 'Variable name'; Expression = { $_.Name } }, Value
    }

    Section 'Resources' {
        $InputObject.ARMTemplate.Resources | Table -Property @{ Name = 'Resource name'; Expression = { $_.Name } }, Type, Location
    }

    # Generate example command line
    Section 'Use the template' {
        Section 'PowerShell' {
            'New-AzResourceGroupDeployment -Name <deployment-name> -ResourceGroupName <resource-group-name> -TemplateFile <path-to-template>' | Code powershell
        }

        Section 'Azure CLI' {
            'az group deployment create --name <deployment-name> --resource-group <resource-group-name> --template-file <path-to-template>' | Code text
        }
    }

    Section 'ARM Preview' {
        $InputObject.ARMPreview
    }
}