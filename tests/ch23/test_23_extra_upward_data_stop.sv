/*
:name: test_23_extra_upward_data_stop
:description: An upward reference stops after a path component matches a structure object, so the member is resolved in that scope and not in a higher module that has the same name (IEEE 1800-2023 Section 23.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_upward_data_stop.expected
*/
// IEEE 1800-2023 §23.8: the upward search of step b) looks in the parent
// scope for a scope named scope_name and resolves item_name downward from
// it. If a component of the item name matches the name of a structure,
// union, class or covergroup object, no further upward steps occur even if
// the item name does not find a match.
// The leaf module refers to s.x. It has no s, so the search goes to its
// parent mid, which has the packed structure s. That component matches a
// structure object, so the search must stop in mid and resolve x there; the
// x of mid is 4. The top module also has a structure s with x = 9, but it
// is not consulted, because a failed match after the structure object would
// not continue upward. A tool that kept searching would print 9 instead of
// 4.
// Icarus Verilog 13.0 and Verilator 5.052 do not resolve this upward
// reference through a structure object, so this expected output follows the
// standard alone; see the note below.

typedef struct packed {
  int y;
  int x;
} uds_t;

module uds_leaf;
  initial #1 $display("x=%0d", s.x);
endmodule

module uds_mid;
  uds_t s;
  initial s.x = 4;
  uds_leaf l();
endmodule

module test_23_extra_upward_data_stop;
  uds_t s;
  initial s.x = 9;
  uds_mid m();

  initial #2 $finish;
endmodule
