/*
:name: test_illegal_rand_mode_override
:description: A class that declares its own rand_mode() method, overriding the built-in one, is an error (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class declares a method named rand_mode, but the built-in rand_mode() cannot be overridden
:expected_stderr_regex: test_illegal_rand_mode_override\.sv:23:
*/
// IEEE 1800-2023 §18.8: the rand_mode() method is built in and cannot be
// overridden. rmo_obj declares a function rand_mode with the prototype of the
// built-in setter.
// Icarus Verilog 13.0 does not support randomize(), so its error does not
// count.

class rmo_obj;
  rand int v;
  int calls;
  function void rand_mode(bit on_off);   // illegal: overrides the built-in method
    calls++;
  endfunction
endclass

module test_illegal_rand_mode_override;
  rmo_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
