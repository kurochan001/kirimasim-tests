/*
:name: test_bits_member_through_null_handle
:description: $bits of a class member named through a null handle gives the member's width, since the expression is not evaluated (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_member_through_null_handle.expected
*/
// IEEE 1800-2023 §20.6.2: $bits gives the number of bits of its argument's
// type without evaluating the argument. So $bits(p.value) is the width of
// the member value even while the handle p is null, also for a member whose
// type is a parameter of a parameterized class (8.25).

class item_base #(type DATA = int);
  DATA value;
endclass

class plain;
  byte value;
  logic [11:0] w;
endclass

module test_bits_member_through_null_handle;
  item_base #(shortint) p;
  plain q;

  initial begin
    $display("p == null: %0d, $bits(p.value) = %0d", p == null, $bits(p.value));
    $display("q == null: %0d, $bits(q.value) = %0d, $bits(q.w) = %0d", q == null,
             $bits(q.value), $bits(q.w));
  end
endmodule
