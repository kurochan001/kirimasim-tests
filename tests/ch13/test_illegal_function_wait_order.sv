/*
:name: test_illegal_function_wait_order
:description: a function cannot contain a wait_order statement (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function check_order contains wait_order
:expected_stderr_regex: test_illegal_function_wait_order\.sv:26:
*/
// IEEE 1800-2023 13.4 a): a function shall not contain time-controlling
// statements, and wait_order is one of them; it waits until the events are
// triggered in the given order (15.5.4). The function check_order contains
// one. Without that line the design prints ok=1.
// Icarus Verilog 13.0 does not parse wait_order, and the 5.054 release
// of Verilator reports it as unsupported; neither error counts.

module test_illegal_function_wait_order;
  event first, second;
  int ok = 0;

  function void check_order();
    wait_order (first, second);   // illegal: wait_order in a function
    ok = 1;
  endfunction

  initial begin
    check_order();
    $display("ok=%0d", ok);
  end
endmodule
