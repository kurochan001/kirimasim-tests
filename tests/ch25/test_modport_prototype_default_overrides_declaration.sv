/*
:name: test_modport_prototype_default_overrides_declaration
:description: A call through a modport that imports a subroutine with a full prototype uses the default argument value of the prototype, not the one of the declaration (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7 13.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_prototype_default_overrides_declaration.expected
*/
// IEEE 1800-2023 §25.7: a default argument value that a call through a
// modport needs shall be given in the prototype of the modport; when both the
// prototype and the declaration give a default for an argument, the values
// may differ, and the one of the prototype is used. A modport that uses a
// default argument value has to import the subroutine with a full prototype.
// The function scale of pdo_bus returns x * k, with k = 3 by default in its
// declaration. The modport pro imports it with the prototype default k = 10,
// and the modport same with k = 3.
// - pdo_user calls p.scale(4) through pro: 4 * 10 = 40, and p.scale(4, 2)
//   with an explicit k: 8.
// - pdo_same calls s.scale(4) through same: 12.
// - The top calls bus.scale(4) through the instance, not through a modport,
//   which uses the declaration default: 12.
// The task add of the same interface shows the rule for a task: through pro
// its prototype default 100 is added, through the instance its declaration
// default 1, so total is 100 and then 101. The modport pro lists total as an
// input, so that pdo_user can read it through the modport (25.10).
// Icarus Verilog 13.0 does not support subroutines in modports, and the
// 5.052 release of Verilator uses the defaults of the declaration through
// pro (12 and a total of 1).

`timescale 1ns/1ns

interface pdo_bus;
  int total = 0;

  function automatic int scale(input int x, input int k = 3);
    return x * k;
  endfunction

  task automatic add(input int v = 1);
    total += v;
  endtask

  modport pro (input total,
               import function int scale(input int x, input int k = 10),
               import task add(input int v = 100));
  modport same (import function int scale(input int x, input int k = 3));
endinterface

module pdo_user (pdo_bus.pro p);
  initial begin
    #1 $display("through pro: scale(4)=%0d scale(4, 2)=%0d", p.scale(4), p.scale(4, 2));
    p.add();
    $display("through pro: add() total=%0d", p.total);
  end
endmodule

module pdo_same (pdo_bus.same s);
  initial #2 $display("through same: scale(4)=%0d", s.scale(4));
endmodule

module test_modport_prototype_default_overrides_declaration;
  pdo_bus bus ();
  pdo_user u (bus);
  pdo_same v (bus);

  initial begin
    #3 $display("through the instance: scale(4)=%0d", bus.scale(4));
    bus.add();
    $display("through the instance: add() total=%0d", bus.total);
  end
endmodule
