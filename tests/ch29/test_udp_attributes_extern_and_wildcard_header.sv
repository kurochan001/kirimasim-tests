/*
:name: test_udp_attributes_extern_and_wildcard_header
:description: UDP definitions accept attribute instances on the header and on port declarations, extern declarations of the non-ANSI and ANSI header, and a definition with the header ( .* ) after such an extern declaration (IEEE 1800-2023 Section 29.3)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.3 29.3.1 23.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_udp_attributes_extern_and_wildcard_header.expected
*/
// IEEE 1800-2023 §29.3, Syntax 29-1: a UDP header and each UDP port
// declaration may have attribute instances in front of them; a UDP can be
// declared with extern followed by its non-ANSI or ANSI header alone, and
// its definition can then use the header primitive name ( .* ), followed
// by port declarations when the extern header gave only port names, and by
// the table and endprimitive with an optional end label. As for extern
// modules (23.5), ( .* ) stands for the ports of the extern declaration.
// Here u_and has attributes, u_or has a non-ANSI extern header and a ( .* )
// definition, and u_xor an ANSI extern header and a ( .* ) definition. The
// three are used as gates and their outputs are printed for all four input
// pairs.
// Icarus Verilog 13.0 rejects the attribute instances, and Icarus Verilog
// and Verilator 5.052 reject extern primitive declarations (syntax errors).

(* origin = "test" *) primitive u_and(y, a, b);
  (* role = "out" *) output y;
  (* role = "in" *) input a, b;
  table
  // a b : y
     1 1 : 1;
     0 ? : 0;
     ? 0 : 0;
  endtable
endprimitive : u_and

extern primitive u_or(y, a, b);
primitive u_or(.*);
  output y;
  input a, b;
  table
  // a b : y
     1 ? : 1;
     ? 1 : 1;
     0 0 : 0;
  endtable
endprimitive : u_or

extern primitive u_xor(output y, input a, input b);
primitive u_xor(.*);
  table
  // a b : y
     0 0 : 0;
     0 1 : 1;
     1 0 : 1;
     1 1 : 0;
  endtable
endprimitive

module test_udp_attributes_extern_and_wildcard_header;
  logic a, b;
  wire y_and, y_or, y_xor;
  u_and g1(y_and, a, b);
  u_or g2(y_or, a, b);
  u_xor g3(y_xor, a, b);

  initial begin
    for (int i = 0; i < 4; i++) begin
      {a, b} = i[1:0];
      #1 $display("a=%b b=%b: and=%b or=%b xor=%b", a, b, y_and, y_or, y_xor);
    end
  end
endmodule
