/*
:name: test_upward_name_search_after_partial_match
:description: When the first name of scope_name.item_name is not in the current module, the search goes up the instance hierarchy and stops only at a scope where the whole item name matches, going past parent scopes of that name that lack the item (IEEE 1800-2023 Section 23.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_upward_name_search_after_partial_match.expected
*/
// IEEE 1800-2023 §23.8: a name scope_name.item_name that is not found in
// the scopes of the current module is looked for in the scope of the parent
// instance; if a scope of that name is there, the item name is resolved
// downward from it, and the search ends only if all its components match.
// Otherwise the search continues upward (only a match of a structure,
// union, class or covergroup object stops it). The hierarchy is top, mid,
// bot and leaf; leaf names three blocks that it does not have:
//   pb.w: bot has a block pb with w (20), which matches at once;
//   sc.q: bot has a block sc without q, mid has sc with q (40);
//   pc.z: bot and mid have blocks pc without z, top has pc with z (50).
// Stopping at the first scope with the right name would leave sc.q and
// pc.z unresolved. Icarus Verilog 13.0 and Verilator 5.052 stop there and
// reject the design, so this expected output follows the standard alone.

module partial_match_leaf;
  initial #1 $display("leaf: pb.w=%0d sc.q=%0d pc.z=%0d", pb.w, sc.q, pc.z);
endmodule

module partial_match_bot;
  if (1) begin : pb
    int w = 20;
  end
  if (1) begin : sc
    int r = 30;
  end
  if (1) begin : pc
    int r = 31;
  end
  partial_match_leaf leaf();
endmodule

module partial_match_mid;
  if (1) begin : sc
    int q = 40;
  end
  if (1) begin : pc
    int r = 41;
  end
  partial_match_bot bot();
endmodule

module test_upward_name_search_after_partial_match;
  if (1) begin : pc
    int z = 50;
  end
  partial_match_mid mid();
endmodule
