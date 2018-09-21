function dumpeventlog($path){

    foreach ($i in (get-winevent -ListLog * |  ? {$_.RecordCount -gt 0 })) {
        $logName = "eventlog_" + $i.LogName + ".evtx"
        $logName = $logName.replace(" ","-").replace("/", "-").replace("\", "-")
        Write-Host "exporting "$i.LogName" as "$logName
        $bkup = Join-Path $path $logName
        wevtutil epl $i.LogName $bkup
    }
}

function exporthtmleventlog($path){
    $css = Get-Content $eventlogcsspath -Raw
    $js = Get-Content $eventlogjspath -Raw
    $HTMLHeader = @"
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript">$js</script>
<style type="text/css">$css</style>
"@

    foreach ($i in (get-winevent -ListLog * |  ? {$_.RecordCount -gt 0 })) {
        $Report = (get-winevent -LogName $i.LogName)
        $logName = "eventlog_" + $i.LogName + ".html"
        $logName = $logName.replace(" ","-").replace("/", "-").replace("\", "-")
        Write-Host "exporting "$i.LogName" as "$logName
        $Report = $Report | ConvertTo-Html -Title "${i}" -Head $HTMLHeader -As Table
        $Report = $Report | ForEach-Object {$_ -replace "<body>", '<body id="body">'}
        $Report = $Report | ForEach-Object {$_ -replace "<table>", '<table class="sortable" id="table" cellspacing="0">'}
        $bkup = Join-Path $path $logName
        $Report = $Report | Set-Content $bkup
    }
}

function cleareventlog(){
    foreach ($i in (get-winevent -ListLog * |  ? {$_.RecordCount -gt 0 })) {
        wevtutil cl $i.LogName
    }
}


$logPath = "{{ win_dir.event_log }}"
$eventlogcsspath = "C:\\eventlogcss.txt"
$eventlogjspath = "C:\\eventlogjs.txt"

dumpeventlog $logPath
exporthtmleventlog $logPath

rm {{ win_dir.event_log }}\eventlog_*.evtx