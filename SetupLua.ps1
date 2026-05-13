$lualink = "https://sourceforge.net/projects/luabinaries/files/5.5.0/Tools%20Executables/lua-5.5.0_Win64_bin.zip/download"
$rt = $PSScriptRoot
$runluapath = "$rt\lua\run.lnk"
$runluawconsole = "$rt\lua\run-noconsole.lnk"
$runluamain = "$rt\lua\run-mainfile.lnk"
$luamain = "$rt\lua\main.lua"
$binpath ="$rt\lua\bin"
$wluapath = "$binpath\wlua55.exe"
$luapath = "$binpath\lua55.exe"
$zippath = "$binpath\lua-5.5.0_Win64_bin.zip"
function trysetupshortcut {
    if ((Test-Path -Path $wluapath) -and !(Test-Path -Path $runluawconsole)) {
        try {
            Write-Host "Criando atalho para wlua"
            $TargetFile = $wluapath
            $ShortcutFile = $runluawconsole
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.Save()   
        } catch {
           Write-Host "Erro ao criar atalho para wlua"
            return 0
        }
    }
    
    if ((Test-Path -Path $luapath) -and !(Test-Path -Path $runluamain)) {
        try {
            Write-Host "Criando atalho para main.lua"
            $TargetFile = $luapath
            $ShortcutFile = $runluamain
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.Arguments = "..\main.lua"
            $Shortcut.WorkingDirectory = $binpath
            $Shortcut.Save()
            if (!(Test-Path -Path $luamain)) {
            New-Item -Path $luamain -ItemType File -Value @"
print("Hello World!")
io.read()
"@
}
        } catch {
           Write-Host "Erro ao criar atalho para main.lua"
            return 0
        }
    }

    if ((Test-Path -Path $luapath) -and !(Test-Path -Path $runluapath)) {
    
        try {
            Write-Host "Criando atalho para lua"
            $TargetFile = $luapath
            $ShortcutFile = $runluapath
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
            $Shortcut.TargetPath = $TargetFile
            $Shortcut.Save()    
        }
        catch {
            Write-Host "Erro ao criar atalho para lua"
            return 0
        }
    } if ((Test-Path -Path $runluapath) -and (Test-Path -Path $runluawconsole)) {
        return 2
    }
    return 1
}
function tryunziplua {
    if ((Test-Path -Path $zippath) -and !(Test-Path -Path $luapath)) {
        Write-Host "Descompactando arquivos"
    } else {
        return 1
    }
    try {
        Expand-Archive -Path "$zippath" -DestinationPath "$binpath" -Force
        return 1
    }
    catch {
        Write-Host "Falha ao descompactar arquivos"
        return 0
    }
    return 1

}
function downloadlua {
    if (Test-Path -Path $zippath) {
        return 1
    }
    Write-Host "Tentando baixar lua"
    if (!(
        Test-Path -Path "$rt\lua"
        ))
     {
        New-Item -Path "$rt" -ItemType Directory -Name "lua"
    }
    if (!(
        Test-Path -Path $binpath
        ))
    {
        New-Item -Path "$rt\lua" -ItemType Directory -Name "bin"
    }
    if (Test-Path -Path $zippath) {
        return 1
    }
    try {
        curl.exe -L -R $lualink -o $zippath

    }
    catch {
        Write-Host "Erro ao baixar lua"
        return 0
    }
    return 1
}

function main {
    Clear-Host

    $err = $false

    foreach ($i in 1..10) {
        $result = trysetupshortcut
        if ($result -eq 2) {
            break
        }
        if ($result -eq 0) {
            $err = $true
            break
        } 

        $result = tryunziplua
        if ($result -eq 0) {
            $err = $true
            break
        } 
        
        $result = downloadlua
        if ($result -eq 0) {
            $err = $true
            break
        }
    }        
    if ($err) {
        Write-Host "Erro, programa terminando"
    } else {
        Write-Host "Programa finalizado com sucesso"
    }
    Read-Host
}

main
