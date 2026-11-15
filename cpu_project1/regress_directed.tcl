set tests {1 12 2 14 3 17 4 20 5 3 6 26 7 34}
set log "[get_property DIRECTORY [current_project]]/[current_project].sim/sim_1/behav/xsim/simulate.log"
set npass 0
set summary {}
foreach {t exp} $tests {
    set_property -name {xsim.simulate.xsim.more_options} -value "-testplusarg TEST=$t" -objects [get_filesets sim_1]
    launch_simulation
    run 20 us
    close_sim
    set fh [open $log r]
    set txt [read $fh]
    close $fh
    if {[regexp {SCOREBOARD SUMMARY: pass=(\d+) fail=(\d+)} $txt -> p fl] && $p == $exp && $fl == 0} {
        set line "TEST $t: PASS (pass=$p, fail=0)"
        incr npass
    } else {
        set line "TEST $t: FAILED (expected pass=$exp)"
    }
    puts $line
    lappend summary $line
}
set_property -name {xsim.simulate.xsim.more_options} -value {} -objects [get_filesets sim_1]
puts ""
puts "========== DIRECTED TEST SUMMARY =========="
foreach line $summary { puts $line }
puts "DIRECTED: $npass of 7 tests passed"
puts "==========================================="