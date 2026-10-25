/*
:name: test_timeformat_default_arguments
:description: without a $timeformat call, %t prints times in the smallest precision of the `timescale directives, with no fractional digits, no suffix and a minimum field width of 20 (IEEE 1800-2023 Section 20.4.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.3 21.2.1.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeformat_default_arguments.expected
*/
// IEEE 1800-2023 §20.4.3, Table 20-3: until $timeformat is called, %t uses
// as its unit the smallest time precision given by any `timescale directive
// of the design, 0 digits after the decimal point, an empty suffix and a
// minimum field width of 20. A time is given to %t in the time unit of the
// module that prints it and converted to that unit.
// The directives here are 1ns/1ns (first), 1ns/10ps and 1us/100ns (last),
// so %t prints in units of 10 ps: 1.25 ns is 125, 3 ns is 300 and 1 us is
// 100000, each right-justified in 20 columns with nothing after it. Using the
// precision or the unit of the first or the last directive, or of the
// printing module, would print other numbers.

`timescale 1ns/1ns

module test_timeformat_default_arguments;
  tf_default_child u_child();
  tf_default_coarse u_coarse();

  initial begin
    #3;
    $display("top [%t]", $time);
    $display("top [%t]", $realtime);
  end
endmodule

`timescale 1ns/10ps

module tf_default_child;
  initial begin
    #1.25;
    $display("child [%t]", $realtime);
  end
endmodule

`timescale 1us/100ns

module tf_default_coarse;
  initial begin
    #1;
    $display("coarse [%t]", $realtime);
  end
endmodule
