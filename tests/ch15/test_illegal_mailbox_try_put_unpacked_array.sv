/*
:name: test_illegal_mailbox_try_put_unpacked_array
:description: the message of try_put() has to be a singular expression (IEEE 1800-2023 Section 15.4.4)
:tags: ch15
:type: elaboration
:lrm: 1800-2023 15.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the message passed to try_put() is the unpacked array arr, which is not singular
:expected_stderr_regex: test_illegal_mailbox_try_put_unpacked_array\.sv:35:
*/
// IEEE 1800-2023 §15.4.4: the message given to try_put() can be any singular
// expression, object handles included. The mailbox m is typeless, so its
// messages may have any type. An element of arr and a class handle are
// singular and legal; the unpacked array arr itself is not singular.
// Icarus Verilog 13.0 does not support mailboxes, and Verilator 5.052 does not
// support a mailbox without a type parameter; both report errors on other
// lines.

module test_illegal_mailbox_try_put_unpacked_array;
  class item;
    int v = 1;
  endclass
  mailbox m;
  item h;
  int arr [2];
  int r;
  initial begin
    m = new();
    h = new;
    r = m.try_put(arr[0]);
    r = m.try_put(h);
    r = m.try_put(arr);   // illegal
  end
endmodule
