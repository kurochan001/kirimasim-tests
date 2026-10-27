/*
:name: test_ch6_extra_instance_type_identity
:description: A user-defined type declared inside an instance includes the instance in its scope, so the same declaration in two instances makes two distinct types (IEEE 1800-2023 Section 6.22)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22 6.19.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u1.level and u2.level have enum types declared in different instances, so the assignment is between different types
:expected_stderr_regex: test_ch6_extra_instance_type_identity\.sv:37:
*/
// IEEE 1800-2023 §6.22: the scope of a data type identifier includes the
// hierarchical instance scope, so each instance that declares the type
// creates a unique type. To share a type among instances it has to come from
// a package or from the compilation-unit scope. cell declares level_t inside
// the module, so u1.level_t and u2.level_t are different types and the
// assignment on the marked line is illegal (§6.19.3 makes enums strongly
// typed). Assigning u1.level to itself would be legal.
// The 5.052 release of the other simulator accepts the design, so this test
// has no oracle from that simulator.

module test_ch6_extra_instance_type_identity_cell;
  typedef enum {LOW, HIGH} level_t;
  level_t level;
  task set_high();
    level = HIGH;
  endtask
endmodule

module test_ch6_extra_instance_type_identity;
  test_ch6_extra_instance_type_identity_cell u1();
  test_ch6_extra_instance_type_identity_cell u2();
  initial begin
    u2.set_high();
    u1.level = u2.level;   // illegal: two instance-scoped enum types
    $display("u1=%0d", u1.level);
  end
endmodule
