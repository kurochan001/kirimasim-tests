/*
:name: test_illegal_continuous_drive_through_virtual_interface
:description: A continuous drive cannot target a signal through a virtual interface
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a continuous assignment targets a net through a virtual interface handle
:expected_stderr_regex: test_illegal_continuous_drive_through_virtual_interface\.sv:24:(?:\d+:)?[^\n]*(?i:virtual|dynamic[^\n]*outside[^\n]*procedural|(?:constant|static)[^\n]*(?:lhs|assignment|connection)|(?:invalid|unsupported)[^\n]*(?:lhs|continuous|hierarch))
*/
interface continuous_target;
  wire line;
endinterface

module test_illegal_continuous_drive_through_virtual_interface;
  continuous_target concrete();
  virtual continuous_target selected;
  logic source;

  initial selected = concrete;
  assign selected.line = source;
endmodule
