/*
:name: test_sdf_interconnect_load_references
:description: After an INTERCONNECT annotation, every reference to the load port or to what is connected after it, in $display, $monitor or an expression, gives the delayed value, while references to the source and to the net before the load give the undelayed value (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 21.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_load_references.expected
*/
// IEEE 1800-2023 §32.4.4: a reference to an annotated load port, wherever it
// is, in $monitor and $display or in an expression, gives the delayed value;
// a reference to the source gives the undelayed value; references before the
// load give the undelayed value and references at or after the load the
// delayed value. §21.2.3: $monitor prints when one of its arguments changes,
// and once when it is started.
//
// (INTERCONNECT s.o l.i (5)) delays the change of the source port s.o at 10
// by 5 at the load port l.i. Before the load are s.o and the net n of this
// module; at or after it are l.i, the output l.o that follows it, the port p
// of the instance u inside l, which l.i drives, and the expression e = l.i &
// a in this module. At 12 the first group shows 1 and the second 0; at 16
// all show 1. $monitor on l.i, started at 7, prints 0 then and 1 at 15. The
// entry belongs to the cell of this module, named by an empty INSTANCE; the
// test creates its SDF file in the current directory.

`timescale 1ns/1ns

module lr_src (input a, output o);
  assign o = a;
endmodule

module lr_sub (input p);
endmodule

module lr_load (input i, output o);
  assign o = i;
  lr_sub u (i);
endmodule

module test_sdf_interconnect_load_references;
  reg a = 0;
  wire n, lo, e;
  integer f;

  lr_src s (a, n);
  lr_load l (n, lo);
  assign e = l.i & a;

  initial begin
    f = $fopen("test_sdf_interconnect_load_references.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_sdf_interconnect_load_references\") (INSTANCE)");
    $fdisplay(f, "    (DELAY (ABSOLUTE (INTERCONNECT s.o l.i (5)))))");
    $fdisplay(f, ")");
    $fclose(f);
    $sdf_annotate("test_sdf_interconnect_load_references.sdf");
    #7 $monitor("%0d: $monitor l.i=%b", $time, l.i);
    #3 a = 1;      // 10
    #2 $display("%0d: s.o=%b n=%b l.i=%b l.o=%b l.u.p=%b e=%b", $time, s.o, n, l.i, l.o, l.u.p, e);
    #4 $display("%0d: s.o=%b n=%b l.i=%b l.o=%b l.u.p=%b e=%b", $time, s.o, n, l.i, l.o, l.u.p, e);
    $monitoroff;
  end
endmodule
