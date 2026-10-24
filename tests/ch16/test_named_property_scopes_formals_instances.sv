/*
:name: test_named_property_scopes_formals_instances
:description: named properties declared in a module, an interface, a program, a clocking block, a package, the compilation unit, a checker and a generate block are instantiated as whole property specs, before their declaration and as operands; a property formal can stand for a property expression or the whole property spec, formals take defaults, names and casts as for sequences, properties combine with sequences, and disable iff before a property expression makes a property spec (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_property_scopes_formals_instances.expected
*/
// IEEE 1800-2023 §16.12: a named property can be declared in a module, an
// interface, a program, a clocking block, a package, the compilation-unit
// scope, a generate block and a checker. It can be instantiated before its
// declaration, wherever a property spec can be written, and as an operand
// of a property expression. Its evaluation is true or false, and properties
// can be built from properties and sequences. Formals follow the rules of
// sequence formals (defaults, binding by name, casts to typed formals), and
// a formal can also stand for a property expression or for the whole
// property spec. A disable iff clause before a property expression gives a
// property spec, whose attempts are disabled when the condition is true.
// Tick k is at 10 * k + 5. a is high at ticks 1 and 4, b at 2 and 5, c at
// 3, d at 4 and 7; e stays low, and rst is high only around tick 5. The
// sequence properties succeed when their sequence matches; each cover adds
// the times of its successes to its list. d |=> e fails for the attempt at
// tick 7 (85); the one at tick 4 is disabled by rst. The lists are printed at
// the end; the sequence of a clocking block is clocked by it (§16.16).
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// rejects typed and property formals, local variables, default actuals, a
// checker or program in a module, a property in a clocking block, the
// interface instance, a spec as an actual and property instances inside
// and / or; the other lists agree with the standard.

`timescale 1ns/1ns

property p_unit(x, y);
  x ##1 y;
endproperty

package test_named_property_scopes_formals_instances_pkg;
  property p_pkg(x, y);
    x ##2 y;
  endproperty
endpackage

interface test_named_property_scopes_formals_instances_if(input logic x, input logic y);
  property p_if;
    x ##1 y;
  endproperty
endinterface

module test_named_property_scopes_formals_instances;
  logic clk = 0, a = 0, b = 0, c = 0, d = 0, e = 0, rst = 0;
  logic [1:0] w = 2'b10;
  string m[string];
  string order[] = '{"module", "interface", "program", "clocking block", "package",
                      "compilation unit", "checker", "generate block", "empty port list",
                      "local variables", "no semicolon", "before declaration",
                      "property and sequence", "nested instances", "property formal",
                      "spec formal", "default actuals", "typed formal 2'b10",
                      "typed formal 2'b01", "disable iff in declaration",
                      "disable iff in assertion"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  test_named_property_scopes_formals_instances_if u_if(.x(b), .y(c));

  c_late: cover property (@(posedge clk) p_late) hit("before declaration");

  property p_late;
    b ##1 c;
  endproperty

  property p_mod;
    a ##1 b ##1 c;
  endproperty : p_mod

  property p_empty();
    c ##1 !c;
  endproperty

  property p_vars;
    int n;
    bit [1:0] k = 2'd2;
    (a, n = 7) ##1 (b && n == 7 && k == 2'd2);
  endproperty

  property p_nosemi;
    c ##2 b
  endproperty

  property p_outer;
    p_unit(b, c) or p_unit(c, a);
  endproperty

  property p_both(property q, untyped s);
    q and s;
  endproperty

  property p_whole(q);
    q;
  endproperty

  property p_rules(x, y = c, bit z = 1'b1, untyped n = 2);
    x ##n (y && z);
  endproperty

  property p_spec;
    @(posedge clk) disable iff (rst) d |=> e;
  endproperty

  property p_imp(x, y);
    x |=> y;
  endproperty

  if (1) begin : g
    property p_gen;
      b ##3 b;
    endproperty
  end

  clocking cb @(posedge clk);
    property p_cb;
      a ##3 a;
    endproperty
  endclocking

  checker chk(logic ck, logic x, logic y);
    property p_ck;
      @(posedge ck) x ##1 !x ##1 y;
    endproperty
    c_ck: cover property (p_ck) hit("checker");
  endchecker

  chk u_chk(clk, b, a);

  program prg;
    property p_prg;
      b ##0 !a;
    endproperty
    c_prg: cover property (@(posedge clk) p_prg) hit("program");
  endprogram

  c_mod: cover property (@(posedge clk) p_mod) hit("module");
  c_if: cover property (@(posedge clk) u_if.p_if) hit("interface");
  c_cb: cover property (cb.p_cb) hit("clocking block");
  c_pkg: cover property
    (@(posedge clk) test_named_property_scopes_formals_instances_pkg::p_pkg(a, c)) hit("package");
  c_unit: cover property (@(posedge clk) p_unit(a, b)) hit("compilation unit");
  c_gen: cover property (@(posedge clk) g.p_gen) hit("generate block");
  c_empty: cover property (@(posedge clk) p_empty()) hit("empty port list");
  c_vars: cover property (@(posedge clk) p_vars) hit("local variables");
  c_nosemi: cover property (@(posedge clk) p_nosemi) hit("no semicolon");
  c_and: cover property (@(posedge clk) p_unit(a, b) and (a ##2 c)) hit("property and sequence");
  c_outer: cover property (@(posedge clk) p_outer) hit("nested instances");
  c_both: cover property (@(posedge clk) p_both(p_unit(a, b), a ##2 c)) hit("property formal");
  c_whole: cover property (p_whole(@(posedge clk) a ##1 b)) hit("spec formal");
  c_rules: cover property (@(posedge clk) p_rules(a)) hit("default actuals");
  c_rules0: cover property (@(posedge clk) p_rules(.x(b), .z(w), .n(1)))
    hit("typed formal 2'b10");
  c_rules1: cover property (@(posedge clk) p_rules(.x(b), .z(2'b01), .n(1)))
    hit("typed formal 2'b01");
  a_spec: assert property (p_spec) else hit("disable iff in declaration");
  a_spec2: assert property (@(posedge clk) disable iff (rst) p_imp(d, e))
    else hit("disable iff in assertion");

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc, logic vd);
    a = va;
    b = vb;
    c = vc;
    d = vd;
    #10;
  endtask

  initial begin
    #52 rst = 1;   // high at tick 5 (55)
    #6 rst = 0;
  end

  initial begin
    tick(0, 0, 0, 0);   // tick 0
    tick(1, 0, 0, 0);   // tick 1
    tick(0, 1, 0, 0);   // tick 2
    tick(0, 0, 1, 0);   // tick 3
    tick(1, 0, 0, 1);   // tick 4
    tick(0, 1, 0, 0);   // tick 5
    tick(0, 0, 0, 0);   // tick 6
    tick(0, 0, 0, 1);   // tick 7
    tick(0, 0, 0, 0);   // tick 8
    tick(0, 0, 0, 0);   // tick 9
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
