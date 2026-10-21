/*
:name: test_sdf_interconnect
:description: An INTERCONNECT entry delays a signal from an output port to an input port: the source sees the undelayed value and the load the delayed one (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 21.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect.expected
*/
// IEEE 1800-2023 §32.4.4: (INTERCONNECT u1.o u2.i (5)) annotates a delay of 5
// from the output port o of u1 to the input port i of u2. A reference to the
// source yields the undelayed value, and a reference to the load, or to
// anything after it, the delayed value: the net n changes at 10, u2.i and the
// output of u2 at 15. The entry belongs to the cell of this module, named by an
// empty INSTANCE. The test prints the values with $strobe at 10, 14 and 15,
// which shows them at the end of each time step (21.2.2), when the
// continuous assignment in u2 has followed u2.i.

`timescale 1ns/1ns

module sdf_net_src(output o, input i);
  assign o = i;
endmodule

module sdf_net_dst(output o, input i);
  assign o = i;
endmodule

module test_sdf_interconnect;
  reg a = 0;
  wire n, o;
  integer f;

  sdf_net_src u1(n, a);
  sdf_net_dst u2(o, n);

  initial begin
    f = $fopen("test_sdf_interconnect.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_sdf_interconnect\") (INSTANCE)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (INTERCONNECT u1.o u2.i (5))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_interconnect.sdf");
    #10 a = 1;
    $strobe("%0d: n=%b u2.i=%b o=%b", $time, n, u2.i, o);
    #4 $strobe("%0d: n=%b u2.i=%b o=%b", $time, n, u2.i, o);
    #1 $strobe("%0d: n=%b u2.i=%b o=%b", $time, n, u2.i, o);
    #5 $finish;
  end
endmodule
