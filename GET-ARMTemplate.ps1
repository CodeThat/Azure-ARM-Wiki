Function Get-ARMTemplate {
    param (
        [Parameter(Mandatory = $True)]
        [String]$ARMTemplate
    )

    $template = Get-Content $ARMTemplate | ConvertFrom-Json

    #Parameters
    $Parameters = foreach ($property in $template.parameters.PSObject.Properties) {
        [PSCustomObject]@{
            Name        = $property.Name
            Description = $property.Value.metadata.description
        }
    }

    #Variables
    $Variables = foreach ($property in $template.variables.PSObject.Properties) {
        [PSCustomObject]@{
            Name  = $property.Name
            Value = $property.Value
        }
    }


    #Resources
    $Resources = foreach ($property in $template.resources) {
        [PSCustomObject]@{
            Name      = $property.Name
            Type      = $property.Type
            Location  = $property.Location
            DependsOn = $property.DependsOn
        }
    }


    return [PSCustomObject]@{
        'Parameters' = $Parameters
        'Variables'  = $Variables
        'Resources'  = $Resources
    }
}

# Function to create a simple ARM Preview Diagram
Function New-MermaidResourceDiagram {

    [CmdLetBinding()]
    Param ([Parameter (Mandatory = $true)]
        [String] $ARMTemplate
    )

    $InputObject = [pscustomobject]@{
        'ARMTemplate' = Get-ARMTemplate -ARMTemplate $ARMTemplate
    }

    $i = 0

@'
:::mermaid
graph TD
'@
    Foreach ($Resource in $($InputObject.ARMTemplate.Resources)) {
        if ($Resource.DependsOn) {
            m-node -Id $Resource.Type -Attributes @{
                LinkTo = Foreach ($Depends in $Resource.DependsOn) {
                    #Refactor ARM template depends on string
                    ('{0}[{1}]' -f $i, ([regex]::matches($Depends, "'(Microsoft.*?)'").Value).Trim("'", " ").trim("/", " "))
                    $i++
                }
            }
        }
    }
@'
:::
'@
}
