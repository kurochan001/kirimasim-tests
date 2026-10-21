/*
:name: test_sdf_port_delay
:description: A PORT entry of an SDF file annotates an interconnect delay to an input port, so the port and what follows it see the change later than the net that drives it (IEEE 1800-2023 Section 32.4.4)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_port_delay.expected
*/
// IEEE 1800-2023 §32.4.4, Table 32-3: (PORT u2.i (4)) annotates to the port i
// of u2 an interconnect delay from all sources of its net. A reference to the
// source gives the undelayed value and a reference to the load, or to what is
// after it, the delayed value: n changes at 10, u2.i and the output of u2 at
// 14, and the other load u3.i, which the entry does not name, at 10. The test
// prints the values at 12 and 16. The entry belongs to the cell of this
// module, named by an empty INSTANCE.
// Icarus Verilog 13.0 does not read PORT entries.

`timescale 1ns/1ns

module sdf_port_load(output o, input i);
  assign o = i;
endmodule

module test_sdf_port_delay;
  reg n = 0;
  wire o2, o3;
  integer f;

  sdf_port_load u2(o2, n);
  sdf_port_load u3(o3, n);

  initial begin
    f = $fopen("test_sdf_port_delay.sdf", "w");
    $fdisplay(f, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(f, "  (CELL (CELLTYPE \"test_sdf_port_delay\") (INSTANCE)");
    $fdisplay(f, "    (DELAY (ABSOLUTE");
    $fdisplay(f, "      (PORT u2.i (4))))))");
    $fclose(f);
    $sdf_annotate("test_sdf_port_delay.sdf");
    #10 n = 1;
    #2 $display("%0d: n=%b u2.i=%b o2=%b u3.i=%b", $time, n, u2.i, o2, u3.i);
    #4 $display("%0d: n=%b u2.i=%b o2=%b u3.i=%b", $time, n, u2.i, o2, u3.i);
  end
endmodule
