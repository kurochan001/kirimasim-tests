/*
:name: test_module_or_generate_item_attributes
:description: Attribute instances can precede a parameter override, a gate instance, a UDP instance, a module instance and a module common item, in a module and in a generate block; a defparam statement can set several parameters, and a UDP declaration is a description of the source text (IEEE 1800-2023 Section 23.10.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.1 5.12 28.3 29.3 23.3.2 A.1.2 A.1.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_or_generate_item_attributes.expected
*/
// IEEE 1800-2023 A.1.4: a module_or_generate_item is a parameter override
// (defparam followed by a list of defparam assignments, 23.10.1), a gate
// instance (28.3), a UDP instance (29.3), a module instance (23.3.2) or a
// module common item, each after zero or more attribute instances (5.12).
// A.1.2: a UDP declaration is a description of the source text, like the
// declaration of mi_xor here.
// The module has each kind of item with one or two attribute instances, and
// the generate block g_blk has another instance, defparam and gate:
//   - defparam u_leaf.P = 3, u_leaf.Q = 4 sets both parameters, so
//     o1 = P * 10 + Q = 34 (12 with the defaults); in g_blk, defparam
//     u_g.P = 5 gives o2 = 52;
//   - the and gate, the UDP mi_xor and the continuous assignment of y_or
//     follow their truth tables for a, b = 00, 01, 10, 11, as does the or
//     gate of g_blk;
//   - the initial procedure, which also has an attribute instance, prints.
// Icarus Verilog 13.0 stops with a syntax error at the attribute instances
// before the defparam statements and the continuous assignment; without
// them it prints the expected lines.

primitive mi_xor (out, a, b);
  output out;
  input a, b;
  table
    0 0 : 0;
    0 1 : 1;
    1 0 : 1;
    1 1 : 0;
  endtable
endprimitive

module mi_leaf #(parameter int P = 1, parameter int Q = 2) (output int o);
  assign o = P * 10 + Q;
endmodule

module test_module_or_generate_item_attributes;
  logic a = 1'b0, b = 1'b0;
  wire y_and, y_xor, y_or, y_or2;
  int o1, o2;

  (* inst_kind = "leaf" *) mi_leaf u_leaf (o1);
  (* dp_kind = "two" *) defparam u_leaf.P = 3, u_leaf.Q = 4;
  (* gate_kind = 1 *) (* gate_note *) and g_and (y_and, a, b);
  (* udp_kind *) mi_xor u_xor (y_xor, a, b);
  (* assign_kind *) assign y_or = a | b;

  if (1) begin : g_blk
    (* g_inst *) mi_leaf u_g (o2);
    (* g_dp *) defparam u_g.P = 5;
    (* g_gate *) or g_or (y_or2, a, b);
  end

  (* proc_kind = "init" *) initial begin
    for (int i = 0; i < 4; i++) begin
      {a, b} = i[1:0];
      #1 $display("a=%b b=%b and=%b xor=%b or=%b or2=%b", a, b, y_and, y_xor, y_or, y_or2);
    end
    $display("o1=%0d o2=%0d", o1, o2);
  end
endmodule
