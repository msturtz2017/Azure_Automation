param(
    [Parameter(Mandatory = $false)]  
    $ENV
)

Import-Module .\Get-AAPDFFile.psm1 -Force 
$AAPDFConfig = (Get-AAPDFFile -file "$ENV-config*")
$JSONContent = (Get-content $($AAPDFConfig.FullName) -raw | convertfrom-json -depth 100)

foreach ($enity in $JSONContent.enity) {

    switch ($($enity.Settings.action)) {
        new { 
        
            $filename = "$($enity.Settings.name.Substring($enity.Settings.name.IndexOf("-")+1)).psm1"
            $currentFile = (Get-AAPDFFile -file $filename)
            Import-Module $($currentFile.FullName) -Verbose 
            New-AAPDF 
            $moduleToRemove = $($currentFile.Name.Replace(".psm1", ""))            
            Remove-Module $moduleToRemove -Force

            $isRemoved = (Get-Module $moduleToRemove)
            if ($null -ne $isRemoved) {
                Write-Error "The $moduleToRemove was not removed`nPlease check your settings and try again" 
                throw
            } 

            Write-Host "The $moduleToRemove was unload successfully" 
        }
        update {    
            $filename = "$($enity.Settings.name.Substring($enity.Settings.name.IndexOf("-")+1)).psm1"
            $currentFile = (Get-AAPDFFile -file $filename)
            Import-Module $($currentFile.FullName) -Verbose 
            update-AAPDF 
        }
    
        remove {
            $filename = "$($enity.Settings.name.Substring($enity.Settings.name.IndexOf("-")+1)).psm1"
            $currentFile = (Get-AAPDFFile -file $filename)
            Import-Module $($currentFile.FullName) -Verbose 
            remove-AAPDF 
        }   
    }
}