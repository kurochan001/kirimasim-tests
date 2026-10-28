/*
:name: test_interface_extern_and_generate_items
:description: An interface declares an extern function and an extern forkjoin task that connected modules define, and its body holds an attributed initial item, an always_comb, a continuous assignment, a generate region, a loop generate, a conditional generate and an elaboration severity task in a branch that is not elaborated, with modports that export those subroutines and use a modport expression, while the parent module instantiates a module on the interface variables (IEEE 1800-2023 Sections 25.3, 25.7 and A.1.6, A.2.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7 25.3 A.1.6 A.2.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_extern_and_generate_items.expected
*/
// IEEE 1800-2023 A.1.6: an interface_or_generate_item is an optionally
// repeatedly attributed module_common_item or an extern_tf_declaration, and
// an extern_tf_declaration is extern, a method prototype and a semicolon, or
// extern forkjoin, a task prototype and a semicolon. 25.7: the modules
// connected to the interface define the exported subroutines.
//   - ex_fn_bus declares extern function int ext_add(input int x) and
//     exports it in modport fn; ex_fn_target defines it as x + 100, so the
//     initial item of the interface computes 5 + 100 + 2 = 107.
//   - ex_items_bus has an attributed initial item, an always_comb, a
//     continuous assignment, a generate region with a conditional generate,
//     a loop generate and a conditional generate, and an extern forkjoin task
//     that both ex_items_target instances define, each setting its own bit of
//     mask. A module can neither be declared nor instantiated in an interface
//     (25.3), so the parent instantiates ex_leaf and connects it to the
//     interface variables shadow and leaf_y.
//   - Its modport tgt exports the task by identifier and uses the modport
//     expressions .low(shadow[3:0]) and .fixed(2), which are ports visible
//     only through the modport.
// The parent prints the values at time 5: shadow is 8'hA5, plain is its low
// bit, plain2 is 3, gen_n is 1, leaf_y is the inverse of that bit, and
// mask is 2'b11 after the work call.
//
// Icarus Verilog 13.0 does not accept these interfaces and Verilator 5.052
// does not support extern subroutines in an interface or a modport
// expression with a part select.

interface ex_fn_bus;
  int result;

  extern function int ext_add(input int x);

  function automatic int local_double(input int x);
    return 2 * x;
  endfunction

  initial result = ext_add(5) + local_double(1);

  modport fn (export function int ext_add(input int x),
              import function int local_double(input int x));
endinterface

module ex_fn_target (ex_fn_bus.fn b);
  function int b.ext_add(input int x);
    return x + 100;
  endfunction
endmodule

module ex_leaf (input logic a, output logic y);
  assign y = ~a;
endmodule

interface ex_items_bus;
  bit [1:0] mask;
  logic [7:0] shadow;
  logic plain;
  int plain2;
  logic gen_n;
  logic leaf_y;
  genvar g;

  extern forkjoin task work();

  assign shadow = 8'hA5;
  always_comb plain = shadow[0];
  (* keep *) initial plain2 = 3;

  generate
    if (1) begin : gr
      assign gen_n = shadow[0];
    end
  endgenerate

  for (g = 0; g < 2; g++) begin : gl
    if (g == 1) begin : g1
      initial ;
    end
  end

  if (0) begin : gsev
    $fatal(1, "interface generate branch not elaborated");
  end

  modport tgt (export work, output mask, input .low(shadow[3:0]),
               input .fixed(2));
endinterface

module ex_items_target #(parameter int ID = 0) (ex_items_bus.tgt b);
  task b.work();
    b.mask[ID] = 1'b1;
  endtask
endmodule

module test_interface_extern_and_generate_items;
  ex_fn_bus fn_bus ();
  ex_items_bus items_bus ();

  ex_leaf u_leaf (.a(items_bus.shadow[0]), .y(items_bus.leaf_y));

  ex_fn_target u_fn (fn_bus.fn);
  ex_items_target #(0) u_t0 (items_bus.tgt);
  ex_items_target #(1) u_t1 (items_bus.tgt);

  initial begin
    items_bus.work();
    #5 $display("fn result=%0d", fn_bus.result);
    $display("items shadow=%h low=%h plain=%b plain2=%0d gen=%b leaf=%b mask=%b",
             items_bus.shadow, items_bus.shadow[3:0], items_bus.plain,
             items_bus.plain2, items_bus.gen_n, items_bus.leaf_y,
             items_bus.mask);
  end
endmodule
