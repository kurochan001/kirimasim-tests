/*
:name: test_illegal_handle_cast_to_chandle
:description: a class object handle cannot be cast to a chandle
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the marked cast converts an object handle to chandle
:expected_stderr_regex: test_illegal_handle_cast_to_chandle\.sv:27:
*/
// IEEE 1800-2023 8.4: object-handle casts follow the class conversion rules,
// while chandle casts are not generally allowed; a class object handle has no
// cast to chandle. The marked cast is illegal.

class cast_c;
  int v;
endclass

module test_illegal_handle_cast_to_chandle;
  cast_c c;
  chandle h;
  initial begin
    c = new;
    h = chandle'(c); // illegal: object handle cast to chandle
  end
endmodule
