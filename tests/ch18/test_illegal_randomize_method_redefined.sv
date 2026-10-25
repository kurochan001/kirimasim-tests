/*
:name: test_illegal_randomize_method_redefined
:description: a class that declares its own randomize() method, overriding the built-in one, is an error (IEEE 1800-2023 Section 18.6.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class rmr_obj declares a function named randomize, but the built-in randomize() cannot be overridden
:expected_stderr_regex: test_illegal_randomize_method_redefined\.sv:29:
*/
// IEEE 1800-2023 §18.6.3: randomize() is a built-in method of every class
// and cannot be overridden, while pre_randomize() and post_randomize() can.
// rmr_obj overrides post_randomize(), which is legal, and declares a function
// randomize with the prototype of the built-in one, which is the error.
// Icarus Verilog 13.0, which does not support randomize(), accepts the
// design and calls the declared function.

class rmr_obj;
  rand bit [3:0] v;
  int post_calls;

  function void post_randomize();
    post_calls++;
  endfunction

  virtual function int randomize();   // illegal: overrides the built-in method
    v = 4'd5;
    return 1;
  endfunction
endclass

module test_illegal_randomize_method_redefined;
  rmr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
