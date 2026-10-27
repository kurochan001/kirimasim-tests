/*
:name: test_23_extra_bind_placement
:description: Bind directives may appear in a module, in an interface and in the compilation-unit scope, and each inserts its instance into the named target (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_bind_placement.expected
*/
// IEEE 1800-2023 §23.11: a bind directive can be specified in a module, an
// interface or a compilation-unit scope. The three forms have the same
// effect: the bound instantiation is inserted into every instance of the
// named target scope.
//   - bpl_holder has a module-scope bind targeting bpl_mod, whose instance
//     has a = 3;
//   - the interface bpl_bus has a bind targeting bpl_if, whose instance has
//     a = 5;
//   - the compilation-unit bind targets bpl_unit, whose instance has a = 7.
// The probe prints at the delay given by its parameter, so the three lines
// are in a fixed order even though the bind statements are in different
// scopes.
// The 5.052 release of Verilator produces this output; Icarus Verilog 13.0
// has no bind directive.

module bpl_mod(input int a);
endmodule

module bpl_if(input int a);
endmodule

module bpl_unit(input int a);
endmodule

module bpl_probe #(parameter int D = 1) (input int x);
  initial #D $display("x=%0d", x);
endmodule

interface bpl_bus;
  int v = 4;
  bind bpl_if bpl_probe #(.D(2)) pb(.x(a));
endinterface

module bpl_holder;
  bpl_mod u(3);
  bind bpl_mod bpl_probe #(.D(1)) pb(.x(a));
endmodule

bind bpl_unit bpl_probe #(.D(3)) pb(.x(a));

module test_23_extra_bind_placement;
  bpl_unit uu(7);
  bpl_if ui(5);
  bpl_holder h();
  bpl_bus i();

  initial #4 $finish;
endmodule
