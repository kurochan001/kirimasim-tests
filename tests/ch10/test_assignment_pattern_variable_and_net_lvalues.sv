/*
:name: test_assignment_pattern_variable_and_net_lvalues
:description: Assignment patterns with and without a type prefix as the targets of procedural assignments to variables, also holding a concatenation, and of continuous assignments to nets, which deconstruct an unpacked array or structure value element by element in position order (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9 10.3.2 10.4 A.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_pattern_variable_and_net_lvalues.expected
*/
// IEEE 1800-2023 A.8.5: a variable lvalue, and a net lvalue, can be an
// assignment pattern of lvalues, '{lvalue, ...}, optionally after an
// assignment pattern expression type. §10.9: as the left-hand side of an
// assignment-like context the pattern is positional, and each member takes
// the element in the same position of the right-hand value, which has the
// same number of bits; a type before the pattern gives it a self-determined
// type. A continuous assignment (§10.3.2) and a procedural assignment
// (§10.4) are such contexts.
//
//   '{a, b, c} = arr with arr = '{1, 2, 3} gives a 1, b 2, c 3;
//   U'{c, a, b} = '{8'd4, 8'd5, 8'd6} gives c 4, a 5, b 6;
//   hs_t'{{a, b}, c} = hs_t'{16'h0708, 8'h09}: the concatenation {a, b}
//     takes the 16-bit member, a 7 and b 8, and c takes 9;
//   assign '{p1, p2} = src with src = '{6, 9} drives p1 6 and p2 9;
//   assign n2_t'{q1, q2} = n2_t'{4'hA, 4'h5} drives q1 a and q2 5.
//
// Icarus Verilog 13.0 and the 5.052 release of Verilator do not support an
// assignment pattern as an assignment target; the expected output follows
// §10.9 alone.

module test_assignment_pattern_variable_and_net_lvalues;
  typedef byte u_t [3];
  typedef logic [3:0] n2_t [2];
  typedef struct {
    shortint h;
    byte l;
  } hs_t;

  u_t arr = '{1, 2, 3};
  byte a, b, c;
  logic [3:0] src [2] = '{4'h6, 4'h9};
  wire [3:0] p1, p2, q1, q2;

  assign '{p1, p2} = src;
  assign n2_t'{q1, q2} = n2_t'{4'hA, 4'h5};

  initial begin
    '{a, b, c} = arr;
    $display("untyped %0d %0d %0d", a, b, c);
    u_t'{c, a, b} = '{8'd4, 8'd5, 8'd6};
    $display("typed %0d %0d %0d", a, b, c);
    hs_t'{{a, b}, c} = hs_t'{16'h0708, 8'h09};
    $display("concat %0d %0d %0d", a, b, c);
    #1 $display("nets %h %h %h %h", p1, p2, q1, q2);
  end
endmodule
