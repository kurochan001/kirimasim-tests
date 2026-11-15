/*
:name: test_illegal_rand_mode_getter_whole_array
:description: the getter form of rand_mode() accepts only a singular variable, so calling it without an argument on a whole rand unpacked array is an error (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: o.a.rand_mode() calls the getter form on the rand unpacked array a without selecting an element by its index
:expected_stderr_regex: test_illegal_rand_mode_getter_whole_array\.sv:39:
*/
// IEEE 1800-2023 §18.8: rand_mode() called as a nonvoid function, without an
// argument, returns the active state of the specified random variable. This
// form accepts only singular variables, so for an unpacked array one element
// has to be selected by its index. The setter form, with an argument, may name
// the whole array and then affects all its elements.
// The setter on the whole array a, the getter on the element a[1] and the
// getter on the scalar x are legal; the getter on the whole array a is the
// only error.
// Icarus Verilog 13.0 does not support rand_mode(), and the 5.054 release
// of Verilator does not support rand_mode() on an element of an unpacked
// array, so neither error counts.

class rgw_obj;
  rand bit [3:0] a[3];
  rand bit [3:0] x;
endclass

module test_illegal_rand_mode_getter_whole_array;
  rgw_obj o = new;
  int m;

  initial begin
    o.a.rand_mode(0);
    m = o.a[1].rand_mode();
    m = m + o.x.rand_mode();
    m = m + o.a.rand_mode();   // illegal
    $display("m=%0d", m);
  end
endmodule
