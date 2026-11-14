/*
:name: test_illegal_function_expect
:description: a function cannot contain an expect statement (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function check_handshake contains an expect statement
:expected_stderr_regex: test_illegal_function_expect\.sv:29:
*/
// IEEE 1800-2023 13.4 a): a function shall not contain time-controlling
// statements, and expect is one of them; it blocks until its property
// succeeds or fails (16.17). The function check_handshake contains one.
// Without that line the design prints checked=1 and finishes.
// Icarus Verilog 13.0 does not parse expect, and release 5.054 of Verilator
// reports it as unsupported; neither error counts.

module test_illegal_function_expect;
  logic clk = 0;
  logic req = 1, ack = 1;
  int checked = 0;

  always #5 clk = ~clk;

  function void check_handshake();
    expect (@(posedge clk) req ##1 ack);   // illegal: expect in a function
    checked = 1;
  endfunction

  initial begin
    check_handshake();
    $display("checked=%0d", checked);
    $finish;
  end
endmodule
