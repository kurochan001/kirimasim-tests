/*
:name: test_illegal_randc_handle
:description: An object handle shall not be declared randc, so a randc class handle is an error while a rand handle is legal (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class handle h of rch_parent is declared randc
:expected_stderr_regex: test_illegal_randc_handle\.sv:31:
*/
// IEEE 1800-2023 §18.4: an object handle can be declared rand, in which case
// the variables and constraints of the object are solved concurrently with
// those of the containing object, but object handles shall not be declared
// randc. rch_ok has a rand handle and is legal; rch_bad has the randc handle
// h and is illegal.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design, so their results
// do not count.

class rch_child;
  rand int x;
endclass

class rch_ok;
  rand rch_child h;
endclass

class rch_bad;
  randc rch_child h;   // illegal: randc object handle
endclass

module test_illegal_randc_handle;
  rch_bad o = new;

  initial begin
    $display("done");
  end
endmodule
