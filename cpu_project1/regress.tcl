catch {close_sim}
set seeds {}
for {set i 1} {$i <= 50} {incr i} {lappend seeds $i}
set n 100
set projdir [get_property DIRECTORY [current_project]]
set simlog  [file join $projdir [current_project].sim sim_1 behav xsim simulate.log]
set outfile [file join $projdir regress_results.txt]
set out [open $outfile w]
set npass 0
set bad {}
foreach s $seeds {
    set_property -name {xsim.simulate.xsim.more_options} -value "-testplusarg SEED=$s -testplusarg N=$n" -objects [get_filesets sim_1]
    launch_simulation
    run all
    catch {close_sim}
    set fh [open $simlog r]
    set txt [read $fh]
    close $fh
    if {[regexp {SCOREBOARD SUMMARY: pass=(\d+) fail=(\d+)} $txt -> p fl]} {
        set line "seed=$s n=$n pass=$p fail=$fl"
        if {$fl == 0 && $p > 0} {
            incr npass
        } else {
            lappend bad $s
        }
    } else {
        set line "seed=$s n=$n NO SUMMARY FOUND"
        lappend bad $s
    }
    puts $line
    puts $out $line
    flush $out
}
set total "TOTAL: $npass of [llength $seeds] seeds passed"
puts $total
puts $out $total
if {[llength $bad] > 0} {
    puts "FAILED SEEDS: $bad"
    puts $out "FAILED SEEDS: $bad"
}
close $out
puts "done, results in $outfile"
