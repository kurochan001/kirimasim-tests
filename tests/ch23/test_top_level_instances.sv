/*
:name: test_top_level_instances
:description: every module and program that is not instantiated becomes a top-level block, named after its definition, and they can refer to each other by hierarchical names; an instantiated module is not one (IEEE 1800-2023 Section 23.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.1 23.3 23.6 23.9 24.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_top_level_instances.expected
*/
// IEEE 1800-2023 §23.3.1: a module or program that is elaborated but not
// instantiated is implicitly instantiated once at the top of the hierarchy,
// and there can be several such top-level blocks. Their instance names are
// their definition names, so %m prints them alone (§23.3), and one can reach
// another by its hierarchical name, with or without $root (§23.6, §23.9).
// child is instantiated, so it is not a top-level block. The program is a
// top-level block too; when its initial procedure ends, the simulation ends
// (§24.3).

module child;
  initial #3 $display("%m");
endmodule

module top_a;
  int x = 1;
  initial #1 $display("%m: top_b.y = %0d", top_b.y);
endmodule

module top_b;
  int y = 2;
  initial #2 $display("%m: $root.top_a.x = %0d", $root.top_a.x);
endmodule

program top_p;
  initial #5 $display("%m: program");
endprogram

module test_top_level_instances;
  child c();
  initial #4 $display("%m");
endmodule
