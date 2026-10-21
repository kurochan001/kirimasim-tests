/*
:name: test_vpi_startup_routines_null_end
:description: The routines of vlog_startup_routines up to its first NULL entry each run once before the simulation starts and can register callbacks, and a routine placed after that NULL entry is not called (IEEE 1800-2023 Section 38.37.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37.2 38.36.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_startup_routines_null_end.c
:expected_stdout: @test_vpi_startup_routines_null_end.expected
*/
// IEEE 1800-2023 §38.37.2: the routines in vlog_startup_routines, an array
// that ends at a NULL entry, are called just after the simulator is invoked;
// they register system tasks and functions, and they can register callbacks
// too. The array here holds two routines, a NULL entry, a third routine and a
// second NULL entry; the array ends at the first NULL, so the third routine is
// never called. Each routine counts its calls, and the first one registers a
// cbStartOfSimulation callback and the second a cbEndOfSimulation callback
// (38.36.3), which print the counts.

module test_vpi_startup_routines_null_end;
  initial #1 $display("design: done");
endmodule
