/*
:name: test_illegal_cg_type_option_formal
:description: a type option initializer shall be a constant expression, so different covergroup instances cannot give a type option different values (IEEE 1800-2023 Section 19.7.1)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: type_option.weight of cg is initialized from the constructor argument w, and g1 and g2 pass different values
:expected_stderr_regex: test_illegal_cg_type_option_formal\.sv:26:
*/
// IEEE 1800-2023 §19.7.1: type options are analogous to static data members
// and can only be initialized with constant expressions, so different
// instances cannot assign different values to them. Covergroup cg2 sets
// type_option.weight from the constant 3 and is instantiated twice. Covergroup
// cg sets type_option.weight from its argument w, and g1 = new(1) and
// g2 = new(2) would give the type two different values; the nonconstant
// initializer is the one error.

module test_illegal_cg_type_option_formal;
  bit [1:0] x;

  covergroup cg (int w);
    type_option.weight = w;   // illegal: not a constant expression
    cp: coverpoint x;
  endgroup

  covergroup cg2;
    type_option.weight = 3;
    cp: coverpoint x;
  endgroup

  cg g1 = new(1);
  cg g2 = new(2);
  cg2 h1 = new;
  cg2 h2 = new;

  initial begin
    $display("not reached");
  end
endmodule
