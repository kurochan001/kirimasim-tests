/*
:name: test_upward_name_resolution_order
:description: Simple names take the nearest declaration and stop at the module for variables, scope_name.item_name looks in the lexical scopes of the module first and then in the parent instances, parent instances can be named by module or instance name, a subroutine of a parent module is found, and an instance name wins over a module of the same name (IEEE 1800-2023 Section 23.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8 23.9 23.8.1 6.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_upward_name_resolution_order.expected
*/
// IEEE 1800-2023 §23.8: a name scope_name.item_name is resolved by looking
// for scope_name first in the current scope and the scopes around it up to
// the module (a found scope makes a downward reference), then in the scope
// of the parent instance, and so on up the hierarchy. A parent can be named
// by its module name or its instance name, and a task or function is looked
// for in the enclosing modules up to the root (also §23.8.1). §23.9: a
// simple name refers to the nearest declaration in the enclosing scopes, but
// the search for a variable stops at the module; and an instance name takes
// precedence over a module of the same name.
// The hierarchy is top, mid (module upward_mid), bot (upward_bot) and leaf
// (upward_leaf); leaf prints:
//   x: the x of the block outer (6), not of the module (5);
//   nb.v: the block nb of leaf (1), not the nb of bot (2);
//   pb.w: pb is not in leaf, so the block pb of bot (20);
//   upward_bot.i and bot.i: the parent by module and by instance name (3);
//   parent_f(): the function of bot (33);
//   upward_mid.val: mid holds an instance named upward_mid, which wins over
//      the module upward_mid of mid itself: its val (70), not mid's (80).
// leaf assigns an undeclared y, which becomes an implicit net of leaf
// (§6.10) and does not reach the variable y of bot: top prints bot.y = 9
// and leaf.y = 1. Icarus Verilog 13.0 prints this output; Verilator 5.052
// does not find the function of the parent module.

module upward_holder;
  int val = 70;
endmodule

module upward_leaf;
  if (1) begin : nb
    int v = 1;
  end
  int x = 5;
  assign y = 1'b1;

  initial begin : outer
    int x;
    x = 6;
    begin : inner
      #1;
      $display("leaf: x=%0d", x);
      $display("leaf: nb.v=%0d", nb.v);
      $display("leaf: pb.w=%0d", pb.w);
      $display("leaf: upward_bot.i=%0d bot.i=%0d", upward_bot.i, bot.i);
      $display("leaf: parent_f()=%0d", parent_f());
      $display("leaf: upward_mid.val=%0d", upward_mid.val);
    end
  end
endmodule

module upward_bot;
  int i = 3;
  int y = 9;
  if (1) begin : nb
    int v = 2;
  end
  if (1) begin : pb
    int w = 20;
  end
  function int parent_f();
    return 33;
  endfunction
  upward_leaf leaf();
endmodule

module upward_mid;
  int val = 80;
  upward_holder upward_mid();
  upward_bot bot();
endmodule

module test_upward_name_resolution_order;
  upward_mid mid();
  initial #2 $display("top: bot.y=%0d leaf.y=%b", mid.bot.y, mid.bot.leaf.y);
endmodule
