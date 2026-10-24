/*
:name: test_named_sequence_scopes_and_instances
:description: named sequences declared in a module, an interface, a program, a clocking block, a package, the compilation unit, a checker and a generate block, with and without a port list, local variable declarations, the final semicolon and a closing label, are instantiated by name, by hierarchical name, before their declaration, inside a larger sequence, with triggered and as an event (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_sequence_scopes_and_instances.expected
*/
// IEEE 1800-2023 §16.8: a named sequence can be declared in a module, an
// interface, a program, a clocking block, a package, the compilation-unit
// scope, a checker and a generate block. The declaration may leave out the
// port list or have an empty one, may declare local variables before the
// sequence expression, may leave out the semicolon after it, and may repeat
// its name after endsequence. An instance can use the plain name, a
// hierarchical name or a package-scoped name, can come before the
// declaration, can be an operand of a larger sequence, and can be used with
// the triggered method or as an event expression. Every instance behaves as
// its body with the actual arguments put in place of the formals.
// a is high at the tick at 15, b at 25 and 45, c at 35. Each cover statement
// and the process waiting on @(s_clk) add the time to the list of its label;
// the lists are printed at the end. The sequence of a clocking block takes
// the clocking event as its clock (§16.16).
// Icarus Verilog 13.0 does not support these assertions; Verilator 5.052
// rejects the checker and the program declared in a module, the sequence in
// a clocking block, triggered and the interface instance (the other lists
// agree with the standard).

`timescale 1ns/1ns

sequence s_unit(x, y);
  x ##1 y;
endsequence

package test_named_sequence_scopes_and_instances_pkg;
  sequence s_pkg(x, y);
    x ##3 y;
  endsequence
endpackage

interface test_named_sequence_scopes_and_instances_if(input logic x, input logic y);
  sequence s_if;
    x ##2 y;
  endsequence
endinterface

module test_named_sequence_scopes_and_instances;
  logic clk = 0, a = 0, b = 0, c = 0;
  string m[string];
  string order[] = '{"module", "interface", "program", "clocking block", "package",
                      "compilation unit", "checker", "generate block", "empty port list",
                      "local variables", "no semicolon", "before declaration", "operand",
                      "triggered", "event"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  test_named_sequence_scopes_and_instances_if u_if(.x(a), .y(c));

  c_late: cover sequence (@(posedge clk) s_late) hit("before declaration");

  sequence s_late;
    b ##1 c;
  endsequence

  sequence s_mod;
    a ##1 b;
  endsequence : s_mod

  sequence s_empty();
    c ##1 b;
  endsequence

  sequence s_vars;
    int n;
    bit [1:0] k = 2'd1;
    (a, n = 5) ##1 (b && n == 5 && k == 2'd1);
  endsequence

  sequence s_nosemi;
    a ##3 b
  endsequence

  sequence s_clk;
    @(posedge clk) a ##1 b;
  endsequence

  if (1) begin : g
    sequence s_gen;
      b ##2 b;
    endsequence
  end

  clocking cb @(posedge clk);
    sequence s_cb;
      a ##1 b ##1 c;
    endsequence
  endclocking

  checker chk(logic ck, logic x, logic y);
    sequence s_ck;
      x ##1 !x ##1 y;
    endsequence
    c_ck: cover sequence (@(posedge ck) s_ck) hit("checker");
  endchecker

  chk u_chk(clk, a, c);

  program prg;
    sequence s_prg;
      b ##0 !a;
    endsequence
    c_prg: cover sequence (@(posedge clk) s_prg) hit("program");
  endprogram

  c_unit: cover sequence (@(posedge clk) s_unit(a, b)) hit("compilation unit");
  c_pkg: cover sequence (@(posedge clk) test_named_sequence_scopes_and_instances_pkg::s_pkg(a, b))
    hit("package");
  c_if: cover sequence (@(posedge clk) u_if.s_if) hit("interface");
  c_mod: cover sequence (@(posedge clk) s_mod) hit("module");
  c_gen: cover sequence (@(posedge clk) g.s_gen) hit("generate block");
  c_cb: cover sequence (cb.s_cb) hit("clocking block");
  c_empty: cover sequence (@(posedge clk) s_empty()) hit("empty port list");
  c_vars: cover sequence (@(posedge clk) s_vars) hit("local variables");
  c_nosemi: cover sequence (@(posedge clk) s_nosemi) hit("no semicolon");
  c_operand: cover sequence (@(posedge clk) s_mod ##2 b) hit("operand");
  c_trig: cover property (@(posedge clk) s_clk.triggered) hit("triggered");

  initial forever @(s_clk) hit("event");

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc);
    a = va;
    b = vb;
    c = vc;
    #10;
  endtask

  initial begin
    tick(0, 0, 0);   // 5
    tick(1, 0, 0);   // 15
    tick(0, 1, 0);   // 25
    tick(0, 0, 1);   // 35
    tick(0, 1, 0);   // 45
    tick(0, 0, 0);   // 55
    tick(0, 0, 0);   // 65
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
