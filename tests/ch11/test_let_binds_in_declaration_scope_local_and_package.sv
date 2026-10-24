/*
:name: test_let_binds_in_declaration_scope_local_and_package
:description: names in a let body that are not formal arguments are resolved where the let is declared, not where it is used, a let is local to its scope, so two modules can declare different lets of the same name, and a let can come from a package by import or by package scope (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_binds_in_declaration_scope_local_and_package.expected
*/
// IEEE 1800-2023 §11.12: a variable in a let body that is not a formal
// argument is resolved by the scoping rules of the scope where the let is
// declared. A let has a local scope, unlike a text macro, whose definition
// holds for the rest of the compilation unit, and lets can be put in
// packages and used from there.
// xp1 is declared in the module and uses the module variable x (5): inside a
// block and inside a task that each declare their own x (12 and 9) it still
// gives 6. addbase is declared in the package p_let and uses the package
// variable base (100), although the module that imports it declares its own
// base (1): addbase(1) is 101. p_let::scale(2) uses the package let by
// package scope (6), while the modules m_a and m_b each declare their own
// scale and get 20 and 40 from it.
// Icarus Verilog 13.0 does not parse let declarations.

package p_let;
  int base = 100;
  let addbase(v) = v + base;
  let scale(v) = v * 3;
endpackage

module m_a;
  let scale(v) = v * 10;
  function automatic int run(int v);
    return scale(v);
  endfunction
endmodule

module m_b;
  let scale(v) = v * 20;
  function automatic int run(int v);
    return scale(v);
  endfunction
endmodule

module test_let_binds_in_declaration_scope_local_and_package;
  import p_let::*;
  int base = 1;
  logic [3:0] x = 4'd5;
  let xp1 = x + 4'd1;

  m_a ua ();
  m_b ub ();

  task automatic t_local();
    logic [3:0] x = 4'd9;
    $display("task with its own x = %0d: %0d", x, xp1);
  endtask

  initial begin
    #1;
    begin
      logic [3:0] x;
      x = 4'd12;
      $display("block with its own x = %0d: %0d", x, xp1);
    end
    t_local();
    $display("package lets: %0d %0d, module base %0d", addbase(1), p_let::scale(2), base);
    $display("module lets of the same name: %0d %0d", ua.run(2), ub.run(2));
  end
endmodule
