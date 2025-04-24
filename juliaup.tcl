# a simple Tk application using the juliaup utility to manipulate installed Julia versions

package require Tk

proc setJuliaupLocation {} {
    try {
        set results [exec where juliaup]
        global jloc
        set jloc $results
    } trap CHILDSTATUS {results options} {
        return 0
    }
    
}

#exec juliaup doesn't work for some reason
proc juliaupAdd {version} {
    exec juliaup add $version
}

proc juliaupList {} {
    exec juliaup list
}

proc juliaupStatus {} {
    exec juliaup status
}

proc juliaupSetDefault {version} {
    exec juliaup default $version
}

proc parseStatus {statusStr} {

}

#setup windows

wm title . {Juliaup}
button .setjuliaup -text "Set Juliaup"
button .setDefault -text "Set Default"
listbox .juliaInstalledVers 
grid configure .setjuliaup . -column 2
grid configure .setDefault . -column 2
grid configure .juliaInstalledVers . -column 1
.juliaInstalledVers insert end [juliaupStatus]
