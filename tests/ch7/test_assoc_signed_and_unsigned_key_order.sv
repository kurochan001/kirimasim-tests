/*
:name: test_assoc_signed_and_unsigned_key_order
:description: Equal high-bit key patterns have different signed and unsigned traversal orders (IEEE 1800-2023 Section 7.8.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_assoc_signed_and_unsigned_key_order.expected
*/
// Insert equal bit patterns in both arrays. Observe every key and value.
// Their order differs from insertion order and from signedness reversal.

module test_assoc_signed_and_unsigned_key_order;
  typedef bit signed [7:0] signed_key_t;
  typedef bit [7:0] unsigned_key_t;
  int s[signed_key_t], u[unsigned_key_t];
  initial begin
    s[8'h80] = 1; s[8'hff] = 2; s[8'h00] = 3;
    u[8'h80] = 1; u[8'hff] = 2; u[8'h00] = 3;
    foreach (s[k]) $display("signed: %0d=%0d", k, s[k]);
    foreach (u[k]) $display("unsigned: %0d=%0d", k, u[k]);
    $display("sizes=%0d,%0d", s.num(), u.num());
  end
endmodule
