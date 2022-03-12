$CMK_VERSION = "2.0.0p9"
## VEEAM Backups key
## This powershell script needs to be run with the 64bit powershell
## and thus from a 64bit check_mk agent
## If a 64 bit check_mk agent is available it just needs to be renamed with
## the extension .ps1




Function ConvertTo-LocalTime {
    <#
    .Synopsis
    Convert a remote time to local time
    .Description
    You can use this command to convert datetime from another timezone to your local time. You should be able to enter the remote time using your local time and date format.
    .Parameter Time
    Specify the date and time from the other time zone.
    .Parameter TimeZone
    Select the corresponding time zone.
    .Example
    PS C:\> ConvertTo-LocalTime "2/2/2021 2:00PM" -TimeZone 'Central Europe Standard Time'

    Tuesday, February 2, 2021 8:00:00 AM

    Convert a Central Europe time to local time, which in this example is Eastern Standard Time.
    .Example
    PS C:\> ConvertTo-LocalTime "7/2/2021 2:00PM" -TimeZone 'Central Europe Standard Time' -Verbose
    VERBOSE: Converting Friday, July 2, 2021 2:00 PM [Central Europe Standard Time 01:00:00 UTC] to local time.
    Friday, July 2, 2021 9:00:00 AM

    The calculation should take day light savings time into account. Verbose output indicates the time zone and its UTC offset.

    .Notes
    Learn more about PowerShell: https://jdhitsolutions.com/blog/essential-powershell-resources/
    .Inputs
    None
    .Link
    Get-Date
    .Link
    Get-TimeZone
    #>
    [cmdletbinding()]
    [alias("ctlt")]
    [Outputtype([System.Datetime])]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify the date and time from the other time zone. ")]
        [ValidateNotNullorEmpty()]
        [alias("dt")]
        [string]$Time,
        [Parameter(Position = 1, Mandatory, HelpMessage = "Select the corresponding time zone.")]
        [alias("tz")]
        [string]$TimeZone
    )
    #parsing date from a string to accommodate cultural variations
    $ParsedDateTime = Get-Date $time
    $tzone = Get-TimeZone -Id $Timezone
    $datetime = "{0:f}" -f $parsedDateTime

    Write-Verbose "Converting $datetime [$($tzone.id) $($tzone.BaseUTCOffSet) UTC] to local time."

    $ParsedDateTime.AddHours(-($tzone.BaseUtcOffset.totalhours)).ToLocalTime()
}




# Get Information from veeam backup and replication in cmk-friendly format
# V0.9
# Load Veeam Backup and Replication Powershell Snapin
Add-PSSnapin VeeamPSSnapIn -ErrorAction SilentlyContinue

try
{
write-host "<<<veeam_encryptkey:sep(124)>>>"
$key = Get-VBREncryptionKey

foreach ($keyJob in $key)
    {
        $KeyID = $keyJob.Id
        $KeyDescription = $keyJob.Description
        $KeyModificationDateUtc = ConvertTo-LocalTime -Time $keyJob.ModificationDateUtc -TimeZone 'Central Europe Standard Time'  
        write-host "$KeyID|$KeyDescription|$KeyModificationDateUtc"
    }
    


}

catch
{
$errMsg = $_.Exception.Message
$errItem = $_.Exception.ItemName
Write-Error "Totally unexpected and unhandled error occured:`n Item: $errItem`n Error Message: $errMsg"
Break
}

