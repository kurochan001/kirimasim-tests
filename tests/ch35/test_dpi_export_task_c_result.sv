/*
:name: test_dpi_export_task_c_result
:description: C calls an exported task and an exported function with the same argument list in the same way, but the C result of the task is the disable status, 0 on a normal return and 1 on a return because of a disable, while that of the function is its value (IEEE 1800-2023 Section H.8.2)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.8 H.8.2 35.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_export_task_c_result.c
:expected_stdout: @test_dpi_export_task_c_result.expected
*/
// IEEE 1800-2023 §H.8.2: C calls an exported task as it calls an exported
// function with the same arguments, except that the C result of the task
// is an int with a meaning for disables. §35.8: that int tells whether a
// disable is active on the thread. §35.9: an exported task returns 1 when
// it returns because of a disable and 0 otherwise; the import above it is
// then in the disabled state, which svIsDisabledState shows, and a disabled
// imported task acknowledges by returning 1.
//
// The context task c_run is called from the block worker. It calls the
// exported task sv_step(1, b), which sets its output to 101 and returns
// normally, then the exported function sv_scale(7, b), which sets its
// output to 107 and has the value 21, and then sv_step(2, b), which
// disables worker. Both exports take an input int by value and an output
// int through a pointer. The C code keeps the results, which are printed at
// time 1. The output of the disabled call is undefined (35.9), so it is not
// printed, and the statement after c_run in worker must not run.
//
// Icarus Verilog 13.0 has no DPI. In the 5.054 release of Verilator the C
// result of the exported task is neither 0 nor 1, the disable does not stop
// worker and svIsDisabledState gives 0, so :oracle: names no simulator.

module test_dpi_export_task_c_result;
  import "DPI-C" context task c_run();
  import "DPI-C" function void c_report(output int first_result, output int first_out,
                                        output int func_result, output int func_out,
                                        output int second_result, output int dis_state);
  export "DPI-C" task sv_step;
  export "DPI-C" function sv_scale;

  task sv_step(input int a, output int b);
    b = a + 100;
    if (a == 2)
      disable worker;
  endtask

  function int sv_scale(input int a, output int b);
    b = a + 100;
    return 3 * a;
  endfunction

  initial begin : worker
    c_run();
    $display("worker went on after c_run, which must not happen");
  end

  initial begin
    int first_result, first_out, func_result, func_out, second_result, dis_state;
    #1 c_report(first_result, first_out, func_result, func_out, second_result, dis_state);
    $display("exported task, normal return: C result %0d, output %0d",
             first_result, first_out);
    $display("exported function: C result %0d, output %0d", func_result, func_out);
    $display("exported task, return because of a disable: C result %0d, svIsDisabledState %0d",
             second_result, dis_state);
  end
endmodule
