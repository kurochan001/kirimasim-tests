/*
:name: test_vpi_scope_item_back_relations
:description: A named block gives its logic variables (vpiReg), array variables (vpiRegArray, vpiMemory), named events, named event arrays, parameters, typedefs and let declarations, and a generate block its property and sequence declarations and concurrent assertions; vpiScope of each of them gives that block back (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 9.3.1 11.12 27.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_scope_item_back_relations.c
:expected_stdout: @test_vpi_scope_item_back_relations.expected
*/
// IEEE 1800-2023 §37.12: a scope has one-to-many relations to the items
// declared in it: vpiReg to its logic variables, vpiRegArray and vpiMemory to
// its array variables, vpiNamedEvent, vpiNamedEventArray, vpiParameter,
// vpiTypedef to its typespecs, vpiLetDecl, vpiPropertyDecl, vpiSequenceDecl
// and vpiConcurrentAssertions; each item has a one-to-one relation, vpiScope,
// back to the scope. The named block nb declares one item of each kind that a
// block can hold (9.3.1, 11.12), plus the int variable iv, which is not a
// logic variable; the generate block g holds the declarations that a block
// cannot (27.5). The module itself declares only clk, so items that were put
// in the module instead of nb or g would show as a scope other than nb or g.
// The application prints the sorted names of each iteration and the full
// names of the scopes that vpiScope gives for them.

module test_vpi_scope_item_back_relations;
  logic clk = 1'b0;

  initial begin : nb
    logic lv;
    int iv;
    logic [3:0] la [0:1];
    event ne;
    event nea [0:2];
    localparam int LP = 3;
    typedef logic [2:0] bt;
    let lt(x) = x + LP;
    lv = 1'b0;
    iv = lt(1);
    #1 $vt_scope_items;
  end

  if (1) begin : g
    sequence sd;
      clk;
    endsequence

    property pd;
      @(posedge clk) sd |-> clk;
    endproperty

    ca: assert property (pd);
  end
endmodule
