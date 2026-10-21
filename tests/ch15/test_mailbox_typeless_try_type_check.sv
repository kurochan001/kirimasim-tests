/*
:name: test_mailbox_typeless_try_type_check
:description: On a mailbox without a type parameter, try_get and try_peek return a negative value and leave the message in place when the variable's type is not equivalent to the type of the oldest message, and copy it or take it when it is (IEEE 1800-2023 Section 15.4.6)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.6 15.4.8 15.4.9 15.4.2 6.22.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_typeless_try_type_check.expected
*/
// IEEE 1800-2023 §15.4.9: a mailbox declared without a type parameter is
// typeless; one mailbox carries messages of any type, and it keeps the type
// of each. §15.4.6, §15.4.8: try_get and try_peek return a negative integer
// when the type of the variable is not equivalent to the type of the oldest
// message; only when it is, the message is taken (try_get) or copied
// (try_peek) and the result is positive. §6.22.2: an integral type is
// equivalent to int only when it has 32 bits and 2 states and is signed, so
// bit signed [31:0] is, while bit [31:0] (unsigned) and logic signed [31:0]
// (4-state) are not. num() (15.4.2) shows that the failed calls left both
// messages in the mailbox. Verilator 5.052 rejects the typeless mailbox m,
// as if its type parameter had no default.

module test_mailbox_typeless_try_type_check;
  mailbox m = new();
  int n = 7, i;
  string word = "hi", s;
  bit signed [31:0] same_as_int;
  bit [31:0] unsigned_32;
  logic signed [31:0] four_state_32;
  int r1, r2;

  initial begin
    m.put(n);                   // an int message
    m.put(word);                // then a string message
    r1 = m.try_peek(s);
    r2 = m.try_get(s);
    $display("string from the int: try_peek<0 %0d, try_get<0 %0d, num=%0d", r1 < 0, r2 < 0,
             m.num());
    r1 = m.try_get(unsigned_32);
    r2 = m.try_get(four_state_32);
    $display("bit [31:0]: try_get<0 %0d, logic signed [31:0]: try_get<0 %0d, num=%0d", r1 < 0,
             r2 < 0, m.num());
    r1 = m.try_peek(same_as_int);
    $display("bit signed [31:0]: try_peek>0 %0d, value=%0d, num=%0d", r1 > 0, same_as_int,
             m.num());
    r1 = m.try_get(i);
    $display("int: try_get>0 %0d, value=%0d, num=%0d", r1 > 0, i, m.num());
    r1 = m.try_get(i);
    $display("int from the string: try_get<0 %0d, num=%0d", r1 < 0, m.num());
    r1 = m.try_get(s);
    $display("string: try_get>0 %0d, value=%s, num=%0d", r1 > 0, s, m.num());
  end
endmodule
