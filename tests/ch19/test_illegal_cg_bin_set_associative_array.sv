/*
:name: test_illegal_cg_bin_set_associative_array
:description: a bin set expression yields an associative array instead of a non-associative array (IEEE 1800-2023 Section 19.5.1.2)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5.1.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin set expression of the coverpoint is the associative array aa
:expected_stderr_regex: test_illegal_cg_bin_set_associative_array\.sv:29:
*/
// A bin set expression shall yield a non-associative array whose element type
// is assignment compatible with the coverpoint. The associative array below is
// an array with an index type, not a non-associative array, and it is the bin
// set expression of the coverpoint, which is the error. Icarus Verilog 13.0
// does not implement covergroups, and release 5.052 of the Verilator tool
// rejects every bin set expression of this form as a construct it does not
// support, so neither release shows this rule and the cited clause alone
// decides the test.

module test_illegal_cg_bin_set_associative_array;
  bit [3:0] v;
  int aa[int];

  covergroup cg;
    cp: coverpoint v {
      bins b = aa;   // illegal: an associative array as a set expression
    }
  endgroup

  cg g = new;

  initial begin
    aa[0] = 1;
    v = 0;
    g.sample();
  end
endmodule
