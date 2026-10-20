/*
:name: test_illegal_local_member_outside
:description: A local class property cannot be accessed from outside the class (IEEE 1800-2023 Section 8.18)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.18
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module reads the local property secret of the class vault
:expected_stderr_regex: test_illegal_local_member_outside\.sv:25:
*/
// IEEE 1800-2023 §8.18: a local member is available only to the methods of its
// own class. The module reads it through a handle.

module test_illegal_local_member_outside;
  class vault;
    local int secret = 7;
  endclass

  vault v;
  initial begin
    v = new;
    $display("%0d", v.secret);   // illegal: secret is local
  end
endmodule
