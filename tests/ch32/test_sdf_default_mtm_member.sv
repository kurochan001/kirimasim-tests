/*
:name: test_sdf_default_mtm_member
:description: without an mtm_spec argument $sdf_annotate annotates a value that the simulator selects from the min/typ/max triple of the SDF path, so a triple of 10:20:30 gives a delay of 10, 20 or 30 ns (IEEE 1800-2023 Section 32.9)
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.9 32.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_default_mtm_member.expected
*/
// IEEE 1800-2023 §32.9: the mtm_spec argument of $sdf_annotate selects which
// member of the min/typ/max triples is annotated, and its default value
// TOOL_CONTROL annotates "the value as selected by the simulator". The test
// therefore does not expect one value: it checks that the annotated delay is
// one of the three members. The SDF file gives the path from a to y the triple
// 10:20:30; a is changed at 1 ns, and the time y changes must be 11, 21 or
// 31 ns. A tool that ignored the annotation would change y at 2 ns, and a tool
// that scaled the values would miss all three.
//
// Icarus Verilog 13.0 with -gspecify annotates the typical value, 20 ns, which
// is one of the three; the test prints only that the time is a member of the
// triple, so it does not depend on that choice.

`timescale 1ns/1ns

module sdf_default_buf(input a, output y);
  assign y = a;

  specify
    (a => y) = (1);
  endspecify
endmodule

module test_sdf_default_mtm_member;
  logic a = 0;
  wire y;
  time changed = 0;
  integer fd;

  sdf_default_buf u(.a(a), .y(y));

  always @(y) if (y === 1'b1) changed = $time;

  initial begin
    fd = $fopen("test_sdf_default_mtm_member.sdf", "w");
    $fwrite(fd, "(DELAYFILE (SDFVERSION \"3.0\") (DESIGN \"test_sdf_default_mtm_member\")");
    $fwrite(fd, " (DATE \"x\") (VENDOR \"x\") (PROGRAM \"x\") (VERSION \"x\")");
    $fwrite(fd, " (DIVIDER /) (TIMESCALE 1ns)\n");
    $fwrite(fd, "(CELL (CELLTYPE \"sdf_default_buf\") (INSTANCE u)\n");
    $fwrite(fd, "(DELAY (ABSOLUTE (IOPATH a y (10:20:30) (10:20:30))))))\n");
    $fclose(fd);
    $sdf_annotate("test_sdf_default_mtm_member.sdf", test_sdf_default_mtm_member);
    #1 a = 1;
    #40 $display("change time is a member: %0d",
                (changed == 11) || (changed == 21) || (changed == 31));
  end
endmodule
