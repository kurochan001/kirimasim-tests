/*
:name: test_illegal_dumpports_repeated_filename
:description: two $dumpports calls name the same file (IEEE 1800-2023 Section 21.7.3.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: both $dumpports calls name the file ports.evcd
:expected_stderr_regex: test_illegal_dumpports_repeated_filename\.sv:29:
*/
// Two $dumpports calls may run at the same simulation time, but the same
// file name shall not be specified more than once. Both calls here run
// at time 0 and name ports.evcd.

module m1;
  logic a;
endmodule
module m2;
  logic b;
endmodule
module test_illegal_dumpports_repeated_filename;
  m1 u1();
  m2 u2();
  initial begin
    $dumpports(m1, "ports.evcd");
    $dumpports(m2, "ports.evcd");   // illegal: same file name
  end
endmodule
