/*
:name: test_resetall_default_nettype
:description: `resetall sets compiler directives back to their defaults, so after `default_nettype none it allows implicit nets again (IEEE 1800-2023 Sections 22.3 and 22.8)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.3 22.8 6.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_resetall_default_nettype.expected
*/
// IEEE 1800-2023 §22.8: `default_nettype none makes an undeclared identifier
// an error where an implicit net would otherwise be declared; rb_buf declares
// all its nets. §22.3: `resetall, outside any design element, sets every
// compiler directive with a default back to it, which for `default_nettype is
// wire. So in test_resetall_default_nettype the undeclared y_implicit in the
// port connection is an implicit wire again (6.10).

`default_nettype none

module rb_buf(input wire x, output wire y);
  assign y = ~x;
endmodule

`resetall

module test_resetall_default_nettype;
  logic r = 1'b0;

  rb_buf u(.x(r), .y(y_implicit));

  initial #1 $display("y_implicit = %b, width %0d", y_implicit, $bits(y_implicit));
endmodule
