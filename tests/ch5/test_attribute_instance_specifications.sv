/*
:name: test_attribute_instance_specifications
:description: An attribute instance holds one or more comma-separated attribute specifications before a module, a net, a variable, a module instance, a port connection, an operator and a function call; a specification is an attribute name or a name with a constant expression as its value, and the attributes change no value (IEEE 1800-2023 Section 5.12)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12 A.9.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_attribute_instance_specifications.expected
*/
// IEEE 1800-2023 A.9.1: an attribute instance is (* followed by one or more
// attribute specifications separated by commas and *), and a specification
// is an attribute name or a name, an equals sign and a constant expression.
// §5.12: an attribute instance is a prefix of the language element that
// follows it; an attribute with no value has the type bit and the value 1,
// the attributes are properties of the design for tools, and they do not
// change the behavior. The test puts them before a module, a net, a variable,
// a module instance, a named port connection, a binary operator and a function
// call, in one case with three specifications.
//
// The values are those of the design without the attributes: v and wn are 4'hA,
// x is 8'hA5 + 1 = 8'hA6, the output b of u follows v[0] = 0, the case takes
// the item 8'hA6, and f(3) is 4. Icarus Verilog 13.0 and Verilator 5.052
// produce this output.

`timescale 1ns/1ns

module attr_leaf (input a, output b);
  assign b = a;
endmodule

(* top_attr, width = 8, note = "hi" *)
module test_attribute_instance_specifications;
  logic [3:0] v;
  (* net_attr = 1 *) wire [3:0] wn;
  (* var_attr *) logic [7:0] x = 8'hA5;
  (* inst_attr, level = 2 *) attr_leaf u ((* conn_attr *) .a(v[0]), .b());
  wire bh = u.b;

  assign wn = v;

  function automatic int f(int a);
    return a + 1;
  endfunction

  initial begin
    v = 4'b1010;
    #1;
    x = x + (* op_attr = 3 *) 1;
    $display("attr %h %h %h %b", v, wn, x, bh);
    case (x)
      8'hA6: $display("case a6");
      default: $display("case other");
    endcase
    $display("fn %0d", f (* call_attr *) (3));
  end
endmodule
