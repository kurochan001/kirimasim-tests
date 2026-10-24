/*
:name: test_illegal_mailbox_try_peek_unpacked_array
:description: the argument of try_peek() has to be a singular expression (IEEE 1800-2023 Section 15.4.8)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.4.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the argument of try_peek() is the unpacked array arr, which is not singular
:expected_stderr_regex: test_illegal_mailbox_try_peek_unpacked_array\.sv:30:
*/
// IEEE 1800-2023 §15.4.8: the argument of try_peek() can be any singular
// expression that is a valid left-hand expression. The mailbox m is typeless,
// so its messages may have any type. An element of arr is singular and legal;
// the unpacked array arr itself is not singular.
// Icarus Verilog 13.0 does not support mailboxes, and Verilator 5.052 does not
// support a mailbox without a type parameter; both report errors on other
// lines.

module test_illegal_mailbox_try_peek_unpacked_array;
  mailbox m;
  int arr [2];
  int r;
  initial begin
    m = new();
    m.put(4);
    r = m.try_peek(arr[1]);
    r = m.try_peek(arr);   // illegal
  end
endmodule
