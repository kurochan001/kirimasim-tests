/*
:name: test_23_extra_upward_data_stop
:description: An upward reference that starts with a scope name stops at the first scope where its path, through a structure object, matches, so the member is resolved in that scope and not in a higher module that has the same names (IEEE 1800-2023 Section 23.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_upward_data_stop.expected
*/
// IEEE 1800-2023 §23.8: in a name of the form scope_name.item_name, the
// scope name is a subroutine, an instance or a generate block. When the
// current module has no such scope, step b) looks in the parent scope of the
// instance for it and resolves the item name downward from there; when all
// components match, the search ends with that item, and a component that
// matches a structure, union, class or covergroup object stops further upward
// steps even if the rest does not match.
// The leaf module refers to g.s.x. It has no scope g, so the search goes to
// its parent mid, whose generate block g holds the packed structure s; s.x
// matches there through the structure object, and the x of mid is 4. The top
// module also has a block g with a structure s whose x is 9, but it is not
// consulted. A tool that kept searching would print 9 instead of 4.
// The name starts with the block g because a structure variable is not a
// scope name: a reference s.x alone could not be resolved upward.

typedef struct packed {
  int y;
  int x;
} uds_t;

module uds_leaf;
  initial #1 $display("x=%0d", g.s.x);
endmodule

module uds_mid;
  if (1) begin : g
    uds_t s;
    initial s.x = 4;
  end
  uds_leaf l();
endmodule

module test_23_extra_upward_data_stop;
  if (1) begin : g
    uds_t s;
    initial s.x = 9;
  end
  uds_mid m();

  initial #2 $finish;
endmodule
