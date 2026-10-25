/*
:name: test_illegal_event_control_on_unpacked_array
:description: An event control on a whole unpacked array is illegal, since an event expression has to give a singular value (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event expression of the event control is the unpacked array arr, which is not singular
:expected_stderr_regex: test_illegal_event_control_on_unpacked_array\.sv:25:
*/
// IEEE 1800-2023 §9.4.2: event expressions shall return singular values;
// an aggregate can be used only in an expression that reduces it to a
// singular value, such as the element arr[0] in the first event control.
// The second event control is the whole unpacked array arr.
// The 5.052 release of Verilator accepts the design.

module test_illegal_event_control_on_unpacked_array;
  int arr [0:1];
  int seen = 0;

  always @(arr[0]) seen++;
  always @(arr) seen++;   // illegal: unpacked array in an event expression
endmodule
