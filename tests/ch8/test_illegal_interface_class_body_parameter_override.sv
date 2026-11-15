/*
:name: test_illegal_interface_class_body_parameter_override
:description: In the body of an interface class the parameter keyword declares a local parameter, so a specialization in an implements list that assigns it a value by name is an error (IEEE 1800-2023 Section 8.26.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.1 6.20.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the implements list of bad_c specializes sized_if with a value for SCALE, which the body of sized_if declares with the parameter keyword and which is therefore a local parameter
:expected_stderr_regex: test_illegal_interface_class_body_parameter_override\.sv:42:
*/
// IEEE 1800-2023 §8.26.1: in a parameter declaration that is an item of an
// interface class, the keyword parameter is a synonym for localparam
// (footnote 7 of Syntax 8-3). §6.20.4: a local parameter cannot be changed
// by a parameter value assignment, and §8.25 gives a class specialization
// the parameter override rules of instances. The interface class sized_if
// has the parameter W in its parameter port list and declares SCALE with
// the keyword parameter in its body. good_c implements sized_if #(.W(4)),
// which assigns the port parameter and is legal; bad_c implements
// sized_if #(.SCALE(3)), which assigns the local parameter SCALE: that line
// is the error. The parameters of an interface class are not inherited by
// the classes that implement it (§8.26.3), so the module reads them with
// the class scope resolution operator. Without bad_c the design is legal
// and prints 4 4 2.
// The 5.054 release of Verilator reports on the line of the error that
// SCALE is a local parameter. Icarus Verilog 13.0 does not support
// interface classes.

interface class sized_if #(int W = 8);
  parameter int SCALE = 2;
  pure virtual function int width();
endclass

class good_c implements sized_if #(.W(4));
  virtual function int width();
    return 4;
  endfunction
endclass

class bad_c implements sized_if #(.SCALE(3));   // illegal: SCALE is a local parameter
  virtual function int width();
    return 8;
  endfunction
endclass

module test_illegal_interface_class_body_parameter_override;
  good_c g;

  initial begin
    g = new;
    $display("%0d %0d %0d", g.width(), sized_if#(.W(4))::W, sized_if#(.W(4))::SCALE);
  end
endmodule
