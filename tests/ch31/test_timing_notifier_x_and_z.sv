/*
:name: test_timing_notifier_x_and_z
:description: A violation turns a notifier that holds x into 0 or 1 and leaves a notifier that holds z at z, and the next violation toggles the known value (IEEE 1800-2023 Section 31.6)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.6 31.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_notifier_x_and_z.expected
*/
// IEEE 1800-2023 §31.6 (Table 31-13): a violation changes a notifier from x
// to either 0 or 1, from 0 to 1 and from 1 to 0, and leaves z as it is. The
// standard does not say which of 0 and 1 an x becomes, so the test prints only
// that the value is known after the first violation and toggles at the
// second. nx starts as x, the default of a reg, and nz as z. Both $setup
// checks (31.3.1) see d change 2 before the clock rises at 10 and at 20.

`timescale 1ns/1ns

module test_timing_notifier_x_and_z_dut(input clk, input d);
  reg nx;
  reg nz = 1'bz;

  specify
    $setup(d, posedge clk, 5, nx);
    $setup(d, posedge clk, 5, nz);
  endspecify
endmodule

module test_timing_notifier_x_and_z;
  reg clk = 0, d = 0;
  reg first;

  test_timing_notifier_x_and_z_dut u(clk, d);

  initial begin
    $display("before: nx=%b nz=%b", u.nx, u.nz);
    #8 d = 1;
    #2 clk = 1;          // 10
    #2 clk = 0;
    first = u.nx;
    $display("after the first violation: nx known: %s, nz=%b",
             first === 1'b0 || first === 1'b1 ? "yes" : "no", u.nz);
    #6 d = 0;
    #2 clk = 1;          // 20
    #2 clk = 0;
    $display("after the second violation: nx toggled: %s, nz=%b",
             (first === 1'b0 && u.nx === 1'b1) || (first === 1'b1 && u.nx === 1'b0)
             ? "yes" : "no", u.nz);
  end
endmodule
