/*
:name: test_vpi_put_value_array
:description: vpi_put_value_array sets consecutive elements of a static unpacked array from a start index, and with vpiOneValue sets all of them to a single given value (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_array.c
:expected_stdout: @test_vpi_put_value_array.expected
*/
// IEEE 1800-2023 §38.35: vpi_put_value_array writes num consecutive elements
// of a static unpacked array, starting at the element that the index array
// names, from values in the format given (vpiIntVal here: an array of 32-bit
// integers). With the flag vpiOneValue, the single value given is written to
// all of them. The writes act like vpiNoDelay, so the new values are there
// when the task returns. arr has five elements, all 0 before.

module test_vpi_put_value_array;
  int arr [0:4];

  initial begin
    $vt_fill;
    $display("arr = %0d %0d %0d %0d %0d", arr[0], arr[1], arr[2], arr[3], arr[4]);
  end
endmodule
