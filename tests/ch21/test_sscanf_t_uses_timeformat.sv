/*
:name: test_sscanf_t_uses_timeformat
:description: $sscanf %t reads a floating-point number as a time in the units of $timeformat, rounds it to the number of decimals of $timeformat and stores it in the time unit of the module that calls it (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3 20.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_t_uses_timeformat.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %t matches a floating-point number,
// which is then scaled and rounded as set by $timeformat (20.4.3). Here
// $timeformat(-6, 1, "", 8) makes the unit 1 us with one decimal: 2.46 is
// rounded to 2.5 us, 3.04 to 3.0 us and -1.234e1 to -12.3 us. The values are
// stored in the time unit of the calling module: in ns in the top-level
// module, whose timescale is 1ns/1ps, and in units of 10 ns in u1, whose
// timescale is 10ns/1ns. The values are printed with one decimal at time 1.
// The 5.052 release of Verilator does not round them (2460.0 and so on).

`timescale 10ns/1ns
module t_sub;
  realtime a, b, c;
  initial begin
    #0;
    void'($sscanf("2.46", "%t", a));
    void'($sscanf("3.04", "%t", b));
    void'($sscanf("-1.234e1", "%t", c));
  end
endmodule

`timescale 1ns/1ps
module test_sscanf_t_uses_timeformat;
  realtime a, b, c;
  t_sub u1();

  initial begin
    $timeformat(-6, 1, "", 8);
    void'($sscanf("2.46", "%t", a));
    void'($sscanf("3.04", "%t", b));
    void'($sscanf("-1.234e1", "%t", c));
    #1;
    $display("1ns unit: %0.1f %0.1f %0.1f", a, b, c);
    $display("10ns unit: %0.1f %0.1f %0.1f", u1.a, u1.b, u1.c);
  end
endmodule
