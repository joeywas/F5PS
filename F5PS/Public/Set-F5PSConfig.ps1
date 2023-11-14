function Set-F5PSConfig {
    <#
    .SYNOPSIS
        Set F5 Distributed Cloud configurations to cache in user profile
    
    .DESCRIPTION
        Set F5 Distributed Cloud configurations to cache in user profile
        Saves the information to F5PS/config.json file in user profile
    
    .PARAMETER Uri
        F5 Distributed Cloud Uri. This is the hostname of the F5 console: tenant-name.console.vs.volterra.io
    
    .PARAMETER Token
        F5 Distributed Cloud API token
      
    .EXAMPLE
        Set-F5PSConfig -Uri 'console.ves.volterra.io' -Token 'api-token'
    
    .NOTES
        https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis
        https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials#my-credentials
    #>
        [CmdletBinding()]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '',
            Justification='This function is trivial enough that we do not need ShouldProcess')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
            Justification='its easy to do it this way, is that a good enough excuse?')]
        Param (
            [String]$Uri,
            [String]$Token
        )
        begin {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    
            $cliXmlFile = "$([Environment]::GetFolderPath('ApplicationData'))\F5PS\token.xml"
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] API Token will be stored in $($cliXmlFile)"
    
            $configPath = "$([Environment]::GetFolderPath('ApplicationData'))\F5PS\config.json"
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Configuration will be stored in $($configPath)"
    
            if (-not (Test-Path $configPath)) {
                # If the config file doesn't exist, create it
                $null = New-Item -Path $configPath -ItemType File -Force
            }

            $ExistingConfig = Get-F5PSConfig
    
        } # end begin
    
        process {
            # If no environment ID passed in, and there is existing value, use existing
            if ((-not $Uri) -and ($ExistingConfig.Uri)) {
                $Uri = $ExistingConfig.Uri
            }
            $config = [ordered]@{
                Uri = $Uri
            }
            $config | ConvertTo-Json | Set-Content -Path "$configPath"

            if ($Token) {
                $username = 'F5APIToken'
                $pass = ConvertTo-SecureString $Token -AsPlainText -Force
                [PSCredential]$credential = New-Object System.Management.Automation.PSCredential(
                    $UserName, $pass
                )
                $credential | Export-Clixml $cliXmlFile
            }
    
            if ($AccessToken) {
                $username = 'F5Access'
                $pass = ConvertTo-SecureString $AccessToken -AsPlainText -Force
                [PSCredential]$credential = New-Object System.Management.Automation.PSCredential(
                    $UserName, $pass
                )
                $credential | Export-Clixml $AccessXmlFile
            }
        }
    
        end {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
        }
    } # end function
    