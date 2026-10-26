/*
:name: test_dpi_export_task_result
:description: An exported SystemVerilog task has an int result in C, which is 0 when the task completes normally and passes its input argument to the task, unlike the result of an exported function (IEEE 1800-2023 Sections H.8.2 and 35.9)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.8.2 35.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_task_result.c
:expected_stdout: @test_dpi_export_task_result.expected
*/
// IEEE 1800-2023 §H.8.2: calling an exported SystemVerilog task from C is the
// same as calling an exported function, except that the return type of the
// task is an int whose meaning comes from the disable protocol. §35.9: an
// exported task returns 1 when it returns because of a disable and 0
// otherwise, and the C code reads that int. The arguments are passed as they
// would be for a function with the same formal list.
//
// The C code calls the exported task sv_record with 77 and prints the value it
// gets back, and then calls the exported function sv_recorded, which returns
// what the task stored, so that the call of the task is also seen from
// SystemVerilog. The expected output follows the standard: 0 for the normal
// return and 77 for the stored value. The release used while the test was
// written leaves an undefined value in the result of an exported task; see the
// simulator difference note of this work.

module test_dpi_export_task_result;
  export "DPI-C" task sv_record;
  export "DPI-C" function sv_recorded;
  import "DPI-C" context function void c_call_task();

  int recorded = -1;

  task sv_record(input int x);
    recorded = x;
  endtask

  function int sv_recorded();
    return recorded;
  endfunction

  initial c_call_task();
endmodule
