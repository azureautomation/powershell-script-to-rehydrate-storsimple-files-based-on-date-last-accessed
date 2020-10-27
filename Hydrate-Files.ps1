#requires -version 4

# Script to rehydrate StorSimple files based on date last accessed
# For more information see https://superwidgets.wordpress.com/
# Sam Boutros - 14 March, 2016 - v1.0

#region Input

$FolderName = 'd:\1'
$StartDays  = 15
$EndDays    = 9
# This selection of 15 StartDays and 9 EndDays will rehydrate data whose LastAccessTime was 9-15 days ago.

$LogFile    = "$((Get-Location).Path)\Rehydrate-Files-$(Get-Date -format yyyy-MM-dd_HH-mm-sstt).txt"

#endregion


function Log {
<# 
 .Synopsis
  Function to log input string to file and display it to screen

 .Description
  Function to log input string to file and display it to screen. Log entries in the log file are time stamped. Function allows for displaying text to screen in different colors.

 .Parameter String
  The string to be displayed to the screen and saved to the log file

 .Parameter Color
  The color in which to display the input string on the screen
  Default is White
  Valid options are
    Black
    Blue
    Cyan
    DarkBlue
    DarkCyan
    DarkGray
    DarkGreen
    DarkMagenta
    DarkRed
    DarkYellow
    Gray
    Green
    Magenta
    Red
    White
    Yellow

 .Parameter LogFile
  Path to the file where the input string should be saved.
  Example: c:\log.txt
  If absent, the input string will be displayed to the screen only and not saved to log file

 .Example
  Log -String "Hello World" -Color Yellow -LogFile c:\log.txt
  This example displays the "Hello World" string to the console in yellow, and adds it as a new line to the file c:\log.txt
  If c:\log.txt does not exist it will be created.
  Log entries in the log file are time stamped. Sample output:
    2014.08.06 06:52:17 AM: Hello World

 .Example
  Log "$((Get-Location).Path)" Cyan
  This example displays current path in Cyan, and does not log the displayed text to log file.

 .Example 
  "$((Get-Process | select -First 1).name) process ID is $((Get-Process | select -First 1).id)" | log -color DarkYellow
  Sample output of this example:
    "MDM process ID is 4492" in dark yellow

 .Example
  log "Found",(Get-ChildItem -Path .\ -File).Count,"files in folder",(Get-Item .\).FullName Green,Yellow,Green,Cyan .\mylog.txt
  Sample output will look like:
    Found 520 files in folder D:\Sandbox - and will have the listed foreground colors

 .Link
  https://superwidgets.wordpress.com/category/powershell/

 .Notes
  Function by Sam Boutros
  v1.0 - 08/06/2014
  v1.1 - 12/01/2014 - added multi-color display in the same line

#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [String[]]$String, 
        [Parameter(Mandatory=$false,
                   Position=1)]
            [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
            [String[]]$Color = "Green", 
        [Parameter(Mandatory=$false,
                   Position=2)]
            [String]$LogFile,
        [Parameter(Mandatory=$false,
                   Position=3)]
            [Switch]$NoNewLine
    )

    if ($String.Count -gt 1) {
        $i=0
        foreach ($item in $String) {
            if ($Color[$i]) { $col = $Color[$i] } else { $col = "White" }
            Write-Host "$item " -ForegroundColor $col -NoNewline
            $i++
        }
        if (-not ($NoNewLine)) { Write-Host " " }
    } else { 
        if ($NoNewLine) { Write-Host $String -ForegroundColor $Color[0] -NoNewline }
            else { Write-Host $String -ForegroundColor $Color[0] }
    }

    if ($LogFile.Length -gt 2) {
        "$(Get-Date -format "yyyy.MM.dd hh:mm:ss tt"): $($String -join " ")" | Out-File -Filepath $Logfile -Append 
    } else {
        Write-Verbose "Log: Missing -LogFile parameter. Will not save input string to log file.."
    }
}


#region Identify the files
log 'Getting files from',$EndDays,'to',$StartDays,'Days ago, on folder',$FolderName Green,Cyan,Green,Cyan,Green,Cyan $LogFile
$Duration = Measure-Command {
    try { 
        $Files = Get-ChildItem -Path $FolderName -File -Force -Recurse -ErrorAction Stop |
            where { $_.LastAccessTime -gt (Get-Date).AddDays(- $StartDays) -and $_.LastAccessTime -lt (Get-Date).AddDays(- $EndDays) }
        if ($Files) {
            log 'Found',$Files.Count,'files matching this criteria -', ('{0:N1}' -f (($Files | Measure-Object -property length -sum).sum/1MB)) , '- MB' Green,Cyan,Green,Cyan,Green $LogFile
        } else {
            log 'No files found matching this criteria' Green $LogFile
        }
    } catch {
        log 'Failed to get files under',$FolderName Magenta,Yellow $LogFile
    }
}
log 'Completed file group identification in',"$($Duration.Hours):$($Duration.Minutes):$($Duration.Seconds)",'hh:mm:ss' Green,Cyan,Green $LogFile
#endregion


#region Read the files
if ($Files) {
    $Duration = Measure-Command {
        $Files | % { Get-Content -Path $_.FullName -Force -Raw }
    }
    log 'Finished reading files in',"$($Duration.Hours):$($Duration.Minutes):$($Duration.Seconds)",'hh:mm:ss' Green,Cyan,Green $LogFile
}
#endregion