function Get-AAPDFFile 
{    
    param(

        [Parameter(Mandatory=$true)]
        $file

    )

    $theFile =(Get-ChildItem "$file" -Recurse)

    if($null -ne $($theFile.count))
    {
        if($theFile.Count -gt 1)
        {
            Write-Error "Only one file can be returned`nPlease check your settings and try again"
            throw
        }
    }

    if($null -eq $theFile)
    {
        Write-Error "The variable `$theFile is null`nPlease check your settings and try again"
        throw
    }

    if(!(Test-Path $($theFile.FullName)))
    {
        Write-Error "The the path $($theFile.FullName) is invalid"
        throw
    } 
           
    
    return $theFile
}
     
