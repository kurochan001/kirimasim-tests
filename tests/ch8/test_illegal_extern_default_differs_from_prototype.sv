/*
:name: test_illegal_extern_default_differs_from_prototype
:description: a default argument value repeated in an out-of-block method declaration has to be the same as in the prototype (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the out-of-block declaration of scale gives the default 3 where its prototype gives 2
:expected_stderr_regex: test_illegal_extern_default_differs_from_prototype\.sv:37:
*/
// IEEE 1800-2023 §8.24: an out-of-block declaration matches its prototype
// exactly, except that it may leave out a default argument value of the
// prototype; a default value that it does give shall be syntactically
// identical to one in the prototype. shift leaves its default out and lift
// repeats it, which are legal; scale gives another default value.
// Icarus Verilog 13.0 does not support out-of-block methods. Verilator 5.052
// does not report scale; it takes the omitted default of shift as no default
// and rejects the legal call c.shift(1).

class calc_c;
  extern function int shift(int x, int s = 1);
  extern function int lift(int x, int s = 4);
  extern function int scale(int x, int f = 2);
endclass

function int calc_c::shift(int x, int s);
  return x << s;
endfunction

function int calc_c::lift(int x, int s = 4);
  return x + s;
endfunction

function int calc_c::scale(int x, int f = 3);   // illegal: another default
  return x * f;
endfunction

module test_illegal_extern_default_differs_from_prototype;
  calc_c c = new;
  initial $display("%0d %0d", c.shift(1), c.lift(1));
endmodule
