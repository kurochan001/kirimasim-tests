/*
:name: test_dpi_import_function_zero_time_callers
:description: An imported function completes at once, so it can be called where only code that takes no time can run, such as a native function, always_comb, a final procedure, a delay value and a nonblocking assignment, and time does not advance during its calls (IEEE 1800-2023 Section 35.5.1.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.1 13.4 9.2.3 9.2.2.2 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_function_zero_time_callers.c
:expected_stdout: @test_dpi_import_function_zero_time_callers.expected
*/
// IEEE 1800-2023 §35.5.1.1: an imported function completes its execution
// instantly and consumes no simulation time, as a native function does, so it
// can be called wherever a native function can, including places where time
// cannot pass: in a native function (13.4), in always_comb (9.2.2.2), in a
// final procedure (9.2.3), in the value of a delay and on the right-hand side
// of a nonblocking assignment (10.4.2). c_scale multiplies by 10. At 5,
// scaled_pair calls it twice and $time has not changed afterwards; the delay
// c_scale(1) waits 10, by which time the nonblocking assignment and
// always_comb have their values; after x changes at 15, always_comb follows.

`timescale 1ns/1ns

module test_dpi_import_function_zero_time_callers;
  import "DPI-C" function int c_scale(input int v);

  int x = 3, y, pair, later;
  time start;

  function int scaled_pair(input int v);
    return c_scale(v) + c_scale(v + 1);
  endfunction

  always_comb y = c_scale(x);

  initial begin
    #5 start = $time;
    pair = scaled_pair(2);
    $display("t=%0t: native function gave %0d, %0d time passed", $time, pair, $time - start);
    later <= c_scale(4);
    #(c_scale(1)) $display("t=%0t: nonblocking %0d, always_comb %0d", $time, later, y);
    x = 6;
    #1 $display("t=%0t: always_comb %0d", $time, y);
  end

  final $display("final: %0d", c_scale(9));
endmodule
