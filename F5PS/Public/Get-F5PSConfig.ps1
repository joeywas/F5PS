function Get-F5PSConfig {
    <#
    .SYNOPSIS
        Get default configurations for F5PS from config.json file
    
    .DESCRIPTION
        Get default configurations for F5PS from config.json file
    
    .EXAMPLE
        Get-F5PSConfig
    #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        Param ()
    
        begin {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
            $config = "$([Environment]::GetFolderPath('ApplicationData'))\F5PS\config.json"
            $cliXmlFile = "$([Environment]::GetFolderPath('ApplicationData'))\F5PS\Token.xml"
        }
    
        process {
            $Output = [PSCustomObject]@()
            if (Test-Path $config) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Getting config from [$config]"
                if (Test-Path $cliXmlFile) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Getting Token from [$cliXmlFile]"
                    $TokenCredential = [PSCredential](Import-Clixml $cliXmlFile)
                    $TokenSecret = $TokenCredential.GetNetworkCredential().Password
                } else {
                    $TokenSecret = ''
                }
                $Output = (Get-Content -Path "$config" -ErrorAction Stop | ConvertFrom-Json)
                $Output | Add-Member -MemberType NoteProperty -Name TokenSecret -Value $TokenSecret
            } else {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] No config found at [$config]"
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Use Set-F5PSConfig first."
                return
            }
            $Output
        }
        end {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function complete"
        }
    } # end function
    
    