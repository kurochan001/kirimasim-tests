/*
:name: test_illegal_solve_before_unpacked_array
:description: An unpacked array variable, which is not integral, cannot appear in solve...before (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ordering constraint names the rand unpacked array arr, which is not an integral or real variable
:expected_stderr_regex: test_illegal_solve_before_unpacked_array\.sv:28:
*/
// IEEE 1800-2023 §18.5.9: the variables of an ordering constraint shall be
// rand variables of integral or real type; of an array only its size,
// array.size, is allowed (18.4). solve d.size before x is legal; solve arr
// before x names the whole unpacked array arr, which is not integral.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports does not count; Verilator 5.052 stops with an internal error at the
// legal ordering of d.size.

class sbu_obj;
  rand int x;
  rand int arr[4];
  rand byte d[];
  constraint c { d.size() inside {[1:4]}; foreach (arr[i]) arr[i] < x; }
  constraint o1 { solve d.size before x; }
  constraint o2 { solve arr before x; }   // illegal: arr is not integral
endclass

module test_illegal_solve_before_unpacked_array;
  sbu_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
