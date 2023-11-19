function Invoke-F5APIMethod {
    <#
    .SYNOPSIS
        Connect to the F5 Distributed Cloud API and execute api method

    .DESCRIPTION
        Connect to the F5 Distributed Cloud API

    .PARAMETER Uri
        URI of F5 Distributed Cloud console, for personal accounts it is console.ves.volterra.io
        For organization plans, it is <tenant>.console.ves.volterra.io

    .PARAMETER Token
        API token for F5 Distributed Cloud
    
    .PARAMETER Route
        Route to append to the call

    .EXAMPLE
        Connect-F5

    .NOTES
        https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis
    #>
    [CmdletBinding()]
    param(
        [String]$Uri,
        [String]$Token,
        [String]$Route,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'GET',
        [String]$Body,
        [String]$RestResponseProperty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"

        $config = Get-F5PSConfig
        $Uri = $config.Uri
        $Token = $config.TokenSecret

        if (-not $Uri) {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] URI to F5 Distributed Cloud Console is required. Please use Set-F5PSConfig first. Exiting..."
            return
        } else {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] URI to F5 Distributed Cloud Console: $Uri"
        }

        if (-not $Token) {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] API Token for F5 Distributed Cloud is required. Please use Set-F5PSConfig first. Exiting..."
            return
        } else {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Token: True"
        }

        # If there is no route passed in, use default route of web/namespace
        # list of service previxes are availab here https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis
        if (-not $Route) {
            $Route = 'web/namespaces'
        }

        $BaseUri = "https://$($Uri)/api/$($Route)"
        $Header = @{
            Authorization = "APIToken $Token"
        }
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Header: $($Header | Out-String)"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] BaseUri: $BaseUri"

        try {
            $splatParameter = @{
                Uri = $BaseUri
                Method = $Method
                Header = $Header
            }
            $Content = (Invoke-WebRequest @splatParameter).Content | ConvertFrom-JSON -depth 100
        } catch {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] Problem getting $BaseUri"
            $_
            return
        } # end try catch for invoke web request
        
        if ($RestResponseProperty) {
            ($Content)."$RestResponseProperty"
        } else {
            $Content
        }
        
    } # end process
    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}