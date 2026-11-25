/*
:name: test_selected_default_keyword_set_controls_bit
:description: Select the default keyword set and distinguish an identifier from a keyword
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: selected keyword set value=1
*/

module test_selected_default_keyword_set_controls_bit;
  wire bit = 1'b1;
  initial #1 $display("selected keyword set value=%b", bit);
endmodule
