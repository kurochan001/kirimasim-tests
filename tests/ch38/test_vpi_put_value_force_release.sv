/*
:name: test_vpi_put_value_force_release
:description: vpi_put_value with vpiNoDelay sets a value at once whatever time_p holds, with vpiForceFlag forces a variable and a net at once like a procedural force, and with vpiReleaseFlag releases them at once like a procedural release and returns the value after the release in value_p (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_force_release.c
:expected_stdout: @test_vpi_put_value_force_release.expected
*/
// IEEE 1800-2023 §38.34: with vpiNoDelay, vpi_put_value sets the object to the
// value at once and ignores time_p, which can be NULL. With vpiForceFlag it
// forces the object at once, and with vpiReleaseFlag it releases it at once,
// as the procedural force and release do (10.6.2), time_p being ignored and
// possibly NULL; value_p then receives the value of the object after the
// release. After a release, the variable v keeps its value until its next
// procedural assignment, and the net n, driven by drv, takes the value of its
// driver at once.
//
// The application registers cbAfterDelay callbacks for 5, 15 and 25
// (38.36.2) at the start of the simulation (38.36.3), at time 0. At 5 it puts
// 20 into v with vpiNoDelay and time_p NULL, then 21 with a time_p of 7; at 15
// it forces v to 30 and n to 40; at 25 it releases both. It reads the objects
// right after each call. The design assigns v at 0, 20 and 30 and drv at 0
// and 20, and prints v and n one time unit later.

`timescale 1ns/1ns

module test_vpi_put_value_force_release;
  logic [7:0] v, drv;
  wire [7:0] n;

  assign n = drv;

  initial begin
    v = 1;
    drv = 10;
    #20 v = 2;
    drv = 12;
    #1 $display("21: design v=%0d n=%0d", v, n);
    #9 v = 3;
    #1 $display("31: design v=%0d n=%0d", v, n);
  end
endmodule
