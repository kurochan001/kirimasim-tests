/*
:name: test_inside_array_set_mixed_sign_width
:description: when the set of inside is an unpacked array, each element is compared with the left operand by the rules of ==?, so an element of a narrower signed type is zero-extended against a wider unsigned left operand, the same as when the element is listed on its own (IEEE 1800-2023 Sections 11.4.13, 11.8.1, 11.8.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13 11.8.1 11.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_array_set_mixed_sign_width.expected
*/
// IEEE 1800-2023 §11.4.13: inside traverses an unpacked array in its set down
// to the singular elements and compares each with the left operand by ==?.
// §11.8.1: if one operand is unsigned the comparison is unsigned, and §11.8.2:
// an operand is sign-extended only when the propagated type is signed. So the
// 2-bit signed element 11 is compared with a 3-bit unsigned u as 011: u = 111
// is not inside {s2}, u = 011 is, and {01, 11} does not hold 111 either. A
// 2-bit signed s = 11 is compared as 011 with the unsigned element 111, but as
// 111 with the signed element 111 (both signed: sign extension). Each line
// prints the array form and the same elements listed one by one, which have
// to agree.
//
// Icarus Verilog 13.0 does not support inside. In Verilator 5.052, at both
// seeds, the array form gives 1 on the first and third lines, where the
// listed form gives the right 0, and the fourth line gives 1 in both forms:
// the signed s is sign-extended against the wider unsigned element.

module test_inside_array_set_mixed_sign_width;
  typedef bit signed [1:0] s2_t;
  typedef bit [2:0] u3_t;
  typedef bit signed [2:0] s3_t;
  s2_t s2 [0:0];
  s2_t s2pair [0:1];
  u3_t u3 [0:0];
  s3_t s3 [0:0];
  bit [2:0] u;
  bit signed [1:0] s;

  initial begin
    s2[0] = 2'b11;
    u = 3'b111;
    $display("u=111 in {11}: array=%b listed=%b", u inside {s2}, u inside {s2[0]});
    u = 3'b011;
    $display("u=011 in {11}: array=%b listed=%b", u inside {s2}, u inside {s2[0]});
    s2pair[0] = 2'b01;
    s2pair[1] = 2'b11;
    u = 3'b111;
    $display("u=111 in {01, 11}: array=%b listed=%b", u inside {s2pair},
             u inside {s2pair[0], s2pair[1]});
    s = 2'b11;
    u3[0] = 3'b111;
    $display("s=11 in unsigned {111}: array=%b listed=%b", s inside {u3}, s inside {u3[0]});
    s3[0] = 3'b111;
    $display("s=11 in signed {111}: array=%b listed=%b", s inside {s3}, s inside {s3[0]});
  end
endmodule
