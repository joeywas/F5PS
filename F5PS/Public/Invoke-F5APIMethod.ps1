function Invoke-F5APIMethod {
    <#
    .SYNOPSIS
        Invoke a method in the F5 API. This is a service function to be called by other functions.
    
    .DESCRIPTION
        Invoke a method in the F5 API. This is a service function to be called by other functions.

    .PARAMETER Path
        Path to append to the URL

    .PARAMETER Method
        Defaults to GET
    
    .PARAMETER Headers
        Headers to use. Will be joined with authorization header.
    
    .PARAMETER RestResponseProperty
        Property of the rest response to return as results.
      
    .EXAMPLE
        Invoke-F5APIMethod -RestResponseProperty namespaces
    
    .NOTES
        https://api.F5.com/spec/#/
        https://docs.cloud.f5.com/docs/how-to/volterra-automation-tools/apis
        
    #>
    
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Path,
            [string]$uri,
            [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = 'GET',
            [Hashtable]$Headers,
            [string]$RestResponseProperty,
            [System.Object]$Body
        )
    
        begin {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started. PSBoundParameters: $($PSBoundParameters | Out-String)"
    
    #region Headers
            $config = Get-F5PSConfig
            $token = $config.TokenSecret

            if (-not $uri) {
                $uri = $config.uri
            }

            if (-not $token) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Must first configure an access token with Set-F5PSConfig -Token <token>. Exiting..."
                return
            }
    
            if (-not $uri) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] No uri passed in and no saved uri. Pass in uri or or configure a uri with Set-F5PSConfig -Uri <uri>. Exiting..."
                return
            } else {
                $uri = "https://$($uri)/api/$($Path)"
            }

            $_headers = @{
                Authorization = "API Token $token"
            }

            if ($Headers) {
                $_headers += $Headers
            }

            Write-Verbose "[$($MyInvocation.MyCommand.Name)] URI: [$Uri]"
    
            try {
                $splatParameters = @{
                    Uri = $Uri
                    Method = $Method
                    Headers = $_headers
                }
                # If -body parm is used, we add it to the splat parameters
                if ($body) {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] body: $($body | Out-String)"
                    $splatParameters += @{
                        Body = $body
                    }
                }

                # if contenttype is defined, add it to the parameters
                if ($ContentType) {
                    $splatParameters += @{
                        ContentType = $ContentType
                    }
                }
    
                Write-Debug "[$($MyInvocation.MyCommand.Name)] splatParameters: $($splatParameters | Out-String)"
    
                # Invoke-WebRequest (IWR) to F5. We use IWR instead of Invoke-RestMethod (IRM) because of reasons:
                # 1) IWR is standard from PS version 3 and up. IRM is not
                # 2) IRM doesn't do good job of returning headers and status codes consistently. IWR does.
                #
                # https://www.truesec.com/hub/blog/invoke-webrequest-or-invoke-restmethod
                $Response = Invoke-WebRequest @splatParameters
                $RestResponse = $Response.Content | ConvertFrom-JSON
                $ResponseHeaders = $Response.Headers
                $StatusCode = $Response.StatusCode
    
                Write-Debug "[$($MyInvocation.MyCommand.Name)] RestResponse: $($RestResponse | Out-String)"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] ResponseHeaders: $($ResponseHeaders | Out-String)"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] StatusCode: $($StatusCode | Out-String)"
    
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Problem with Invoke-WebRequest $uri"
                $_
                return
            }
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Executed Invoke-WebRequest"
    
            # If there are bad status codes, this will break and cause function to exit
            #Test-ServerResponse -InputObject $RestResponse -StatusCode $StatusCode
        }
    
        process {
            if ($RestResponse) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] process: RestResponse true"
    
                if ($RestResponseProperty) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] process: RestResponseProperty $($RestResponseProperty)"
                    $result = ($RestResponse).$RestResponseProperty
                } else {
                    $result = $RestResponse
                }

                $result
            } else {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] process: RestResponse false"
            }
        }
        end {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Complete"
        }
    }