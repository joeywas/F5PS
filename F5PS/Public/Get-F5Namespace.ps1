function Get-F5Namespace {
    <#
    .SYNOPSIS
        Get namespaces from F5
    
    .DESCRIPTION
        Get namespaces from F5
    
    .EXAMPLE
        Get-F5Namespace
    #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        Param ()
    
        begin {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
            $Route = 'web/namespaces'
        }
    
        process {
            Invoke-F5APIMethod -Route $Route -RestResponseProperty 'items'
        }

        end {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function complete"
        }
    } # end function
    
    