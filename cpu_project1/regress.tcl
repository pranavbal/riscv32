catch {close_sim}
set seeds {}
for {set i 1} {$i <= 100} {incr i} {lappend seeds $i}
set n 300
set projdir [get_property DIRECTORY [current_project]]
set simlog  [file join $projdir [current_project].sim sim_1 behav xsim simulate.log]
set outfile [file join $projdir regress_results.txt]
set out [open $outfile w]
set npass 0
set bad {}
set total_p 0
set total_f 0
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
        incr total_p $p
        incr total_f $fl
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
set_property -name {xsim.simulate.xsim.more_options} -value {} -objects [get_filesets sim_1]

set nseeds [llength $seeds]
set summary [list \
    "" \
    "========== RANDOM REGRESSION SUMMARY ==========" \
    "Seeds run:       $nseeds (seeds 1-$nseeds, $n instructions each)" \
    "Seeds passed:    $npass" \
    "Seeds failed:    [llength $bad]" \
    "Scoreboard checks: pass=$total_p fail=$total_f" \
    "RANDOM: $npass of $nseeds seeds passed" ]
if {[llength $bad] > 0} {
    lappend summary "FAILED SEEDS: $bad"
}
lappend summary "==============================================="
foreach line $summary {
    puts $line
    puts $out $line
}
close $out
puts "done, results in $outfile"