/*
:name: test_illegal_pure_virtual_final
:description: a pure virtual method cannot be declared final
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure virtual method also has the final specifier
:expected_stderr_regex: test_illegal_pure_virtual_final\.sv:19:
*/
// IEEE 1800-2023 8.20: it is illegal to specify final in a pure virtual
// method declaration. The marked declaration combines pure virtual with
// :final, which a tool has to reject.

class abstract_c;
  pure virtual function :final int f(); // illegal: pure virtual and final
endclass

module test_illegal_pure_virtual_final;
endmodule
