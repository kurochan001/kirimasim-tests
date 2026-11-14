/*
:name: test_illegal_interface_handle_parameter_in_packed_dimension
:description: A parameter read through an interface class handle is not a constant expression, so it cannot bound a packed dimension (IEEE 1800-2023 Section 8.26.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed dimension of bad is bounded by ih.DEPTH, a parameter read through the interface class handle ih, which is not a constant expression
:expected_stderr_regex: test_illegal_interface_handle_parameter_in_packed_dimension\.sv:43:
*/
// IEEE 1800-2023 §8.26.3: the parameters of an interface class are static and
// can be reached with the class scope operator, and reaching them through an
// interface class handle has the restrictions of 8.5: such an expression is
// not a constant expression. A packed dimension needs a constant expression.
// ih is a depth_if#(4) handle that holds a fifo_c object. The module reads
// ih.DEPTH in $display, where any expression is allowed, and bounds the
// packed dimension of ok with depth_if#(4)::DEPTH, a constant expression. The
// packed dimension of bad is bounded by ih.DEPTH. Without the declaration of
// bad the design prints 4 1 4.
// test_illegal_interface_handle_type_parameter checks the other restriction,
// on types.
// Icarus Verilog 13.0 does not support interface classes, so its syntax
// error does not count, and the 5.054 release of Verilator accepts the
// design.

interface class depth_if #(int DEPTH = 2);
  pure virtual function int used();
endclass

class fifo_c implements depth_if #(4);
  virtual function int used();
    return 1;
  endfunction
endclass

module test_illegal_interface_handle_parameter_in_packed_dimension;
  fifo_c f;
  depth_if #(4) ih;
  logic [depth_if#(4)::DEPTH-1:0] ok;
  logic [ih.DEPTH-1:0] bad;   // illegal: ih.DEPTH is not a constant expression

  initial begin
    f = new;
    ih = f;
    $display("%0d %0d %0d", ih.DEPTH, ih.used(), $bits(ok));
  end
endmodule
