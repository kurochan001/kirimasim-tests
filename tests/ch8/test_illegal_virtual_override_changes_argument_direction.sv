/*
:name: test_illegal_virtual_override_changes_argument_direction
:description: A virtual override cannot replace a reference formal with an input formal
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the override changes the direction of the value formal
:expected_stderr_regex: test_illegal_virtual_override_changes_argument_direction\.sv:23:(?:\d+:)?[^\n]*(?i:(?:direction|argument|formal|signature|prototype|virtual override)[^\n]*)
*/
module test_illegal_virtual_override_changes_argument_direction;
  class base_t;
    virtual function int increment(ref int value);
      value++;
      return value;
    endfunction
  endclass

  class derived_t extends base_t;
    function int increment(input int value); // illegal
      value++;
      return value;
    endfunction
  endclass
endmodule
