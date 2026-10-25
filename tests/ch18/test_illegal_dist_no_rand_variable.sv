/*
:name: test_illegal_dist_no_rand_variable
:description: A dist whose expression contains no rand variable is an error (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the expression of the dist in c_bad is the state variable limit, which is not rand
:expected_stderr_regex: test_illegal_dist_no_rand_variable\.sv:25:
*/
// IEEE 1800-2023 §18.5.3: a dist expression shall contain at least one rand
// variable. In c_ok the expression v + limit contains the rand variable v and
// is legal; in c_bad the expression is only limit, a property that is not
// declared rand.
// Icarus Verilog 13.0 does not support dist, so the syntax error it reports
// does not count; Verilator 5.052 accepts the design.

class dnr_obj;
  rand bit [7:0] v;
  bit [7:0] limit = 8'd2;
  constraint c_ok { v + limit dist {[2:9] := 1}; }
  constraint c_bad { limit dist {[0:3] := 1}; }   // illegal: no rand variable
endclass

module test_illegal_dist_no_rand_variable;
  dnr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
