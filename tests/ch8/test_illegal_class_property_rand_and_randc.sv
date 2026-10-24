/*
:name: test_illegal_class_property_rand_and_randc
:description: a class property declaration cannot have both the rand and the randc qualifier (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property both of the class is declared with both rand and randc
:expected_stderr_regex: test_illegal_class_property_rand_and_randc\.sv:29:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 10): in any one declaration only
// one of protected and local is allowed, only one of rand and randc is allowed,
// and static and virtual can each appear only once.
// The class declares a rand property and a randc property, each with one random
// qualifier and an initial value, and a method that adds them; the legal design
// prints the sum without randomizing: 5. The property both is declared rand
// randc.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

class test_illegal_class_property_rand_and_randc_c;
  rand bit [3:0] a = 4;
  randc bit [1:0] b = 1;
  function int sum();
    return a + b;
  endfunction
  rand randc bit [3:0] both;   // illegal: rand and randc together
endclass

module test_illegal_class_property_rand_and_randc;
  test_illegal_class_property_rand_and_randc_c o;
  initial begin
    o = new;
    $display("%0d", o.sum());
  end
endmodule
