param (
    [Parameter(Mandatory=$true)][string] $dataFile,
    [Parameter(Mandatory=$true)][string] $param1,
    [string] $disableCache = "false"
 )

# --------------- CODE RELATED TO DVC ----------------------
$dvcFileName = ".\.dvc.dat"
$dvcBreached = $false
$dvcMetaData = @{}

# if manually set to disable caching
if ($disableCache -eq "true") {
    $dvcBreached = $true
}

# Method toget last modified timestamp of a file $fileName
Function GetLastModifiedTimestamp($fileName) {
    try {
        $beginningOfTime = Get-Date -Date "01/01/1970"
        $x = Get-Item $fileName | select LastWriteTime
        # TODO - should this be milli seconds @category: question
        return (New-TimeSpan -Start $beginningOfTime -End $x.LastWriteTime).TotalSeconds
    }
    catch
    {
        $now = Get-Date
        return (New-TimeSpan -Start $beginningOfTime -End $now).TotalSeconds
    }
}

# updathe the metadata file
Function UpdateDVCMetadata($b) {
    # explort the .dvc.dat metadata
    Export-Clixml -InputObject $dvcMetaData -Path $dvcFileName
}

# if dvc metadata exist, load it to memory
# file name is defined in $dvcFileName
$metaDataExists = Test-Path $dvcFileName
if($metaDataExists -eq $true) {
    $dvcMetaData = Import-Clixml -Path $dvcFileName
}

# in case the input file has changed, the whole pipeline should run again
if ($dvcMetaData["__dataFile"] -ne $dataFile) {
    echo "different input file spotted, cache breach"
    $dvcBreached = $true
}

if ($dvcMetaData["__param1"] -ne $param1) {
    echo "different param1 spotted, cache breach"
    $dvcBreached = $true
}

$dvcMetaData["__dataFile"] = $dataFile
$dvcMetaData["__param1"] = $param1
# --------------- CODE RELATED TO DVC END ----------------------


# name of the output file for next script
$inputFileName = ".\data\data.1year.dedup.csv"
# get it's last modified time
$lastModified = GetLastModifiedTimestamp($inputFileName)

# compare to check if it's same as one stored in metadata
if ($dvcBreached -eq $false -and $lastModified -eq $dvcMetaData[$inputFileName]) {
    # since it's same as last time we need not change it
    echo "$inputFileName loaded from cache skipping operation"
} else {
    # ACTION HERE
    # python abc.py ./data/out.csv $dataFile $inputFileName $param1

    # update the last modified time
    $dvcMetaData[$inputFileName] = GetLastModifiedTimestamp($inputFileName)

    # update the state to meta data file
    # so that even if the next step fails, this is not performed again
    UpdateDVCMetadata($true)


    # set beached as true, as if one file up in pipeline is modified, all other
    # steps need to be taken care of
    $dvcBreached = $true
}

$inputFileName = " .\data\out.preprocessed.pkl"
$lastModified = GetLastModifiedTimestamp($inputFileName)
if ($dvcBreached -eq $false -and $lastModified -eq $dvcMetaData[$inputFileName]) {
    echo "$inputFileName loaded from cache skipping operation"
} else {
    # ACTION HERE
    # python abc.py ./data/out.csv $inputFileName
    $dvcMetaData[$inputFileName] = GetLastModifiedTimestamp($inputFileName)
    $dvcBreached = $true
}

# update the state to meta data file
UpdateDVCMetadata($true)



