/*
:name: test_vpi_size_change_callback
:description: cbSizeChange fires after the size of a dynamic array, a queue, an associative array and a string changes, reports the new size, the string is still empty inside the callback and has the new value later, and a value-only change of an int fires no size callback (IEEE 1800-2023 Section 37.17)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 7.5 7.6 7.8 7.9 38.36
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_size_change_callback.c
:expected_stdout: @test_vpi_size_change_callback.expected
*/
// IEEE 1800-2023 §37.17 detail 14: cbSizeChange applies to dynamic and
// associative arrays, queues and string variables. It fires after the size
// change occurs and before any value changes for that variable, and the value
// it reports is the new size. The application registers cbSizeChange on a
// dynamic array, a queue, an associative array and a string, and
// cbValueChange on an int variable; the design changes them. The string is
// still empty when its size callback fires and holds the new value at the end,
// and the int change produces a value callback but no size callback. The
// recorded lines are sorted because the order between different objects is
// not fixed.

module test_vpi_size_change_callback;
  int d [];
  int q [$];
  int aa [int];
  string s;
  int v;

  initial begin
    d = new[1];
    d[0] = 5;
    q.push_back(7);
    aa[3] = 1;
    s = "ab";
    v = 3;
    #1 $vt_done;
  end
endmodule
