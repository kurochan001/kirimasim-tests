/*
:name: test_illegal_interface_method_default_not_constant
:description: a default argument value of a method of an interface class has to be a constant expression (IEEE 1800-2023 Section 8.26.8)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default value of the argument step of scale_if::scale is the variable gain, which is not a constant expression
:expected_stderr_regex: test_illegal_interface_method_default_not_constant\.sv:30:
*/
// IEEE 1800-2023 §8.26.8: method declarations in interface classes may have
// default argument values; the default expression shall be a constant
// expression, evaluated in the scope that contains the subroutine
// declaration. The defaults 5 and the parameter N of add_if are constant
// expressions, which is legal; the default of scale_if::scale is the
// variable gain of the compilation unit.
// Icarus Verilog 13.0 does not support interface classes, and the design is
// accepted by the 5.052 release of Verilator.

int gain = 3;

interface class add_if #(parameter int N = 2);
  pure virtual function int add(int a, int b = 5, int c = N);
endclass

interface class scale_if;
  pure virtual function int scale(int a, int step = gain);   // illegal: not a constant
endclass

class adder_c implements add_if #(4);
  virtual function int add(int a, int b = 5, int c = 4);
    return a + b + c;
  endfunction
endclass

module test_illegal_interface_method_default_not_constant;
  adder_c h = new;
  initial $display("%0d", h.add(1));
endmodule
