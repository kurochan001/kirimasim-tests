/*
:name: test_wildcard_port_connection_once_any_position
:description: A single .* in a list of port connections, written first, between or after named connections of module and interface instances, connects every other port to the same-named item of the instantiating scope and leaves a port with a default value to its default when no such item exists (IEEE 1800-2023 Section 23.3.2.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.4 A.4.1.1 A.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wildcard_port_connection_once_any_position.expected
*/
// IEEE 1800-2023 §23.3.2.4 with footnote 34 of A.10 (on
// list_of_port_connections, A.4.1.1): the token pair .* appears at most once
// in a list of port connections, and it can be mixed with named connections
// in any order. It connects each port that no named connection lists to the
// item of the same name in the instantiating scope; when that scope has no
// such item, a port with a default value takes its default.
//
// wc_add has inputs a, b and bias (default 7) and the output sum, which is
// a + b + bias. The top module has a = 1, b = 2 and alt = 50, but no bias:
//   u1 (.* first, sum named):           1 + 2 + 7       = 10
//   u2 (.* between b and sum named):    1 + 50 + 7      = 58
//   u3 (.* last, sum and bias named):   1 + 2 + 1000    = 1003
// wc_if is an interface with inputs a and k; wi connects k by name and a by
// .*, so prod = a * k = 1 * 50 = 50.
//
// The 5.052 release of Verilator reports that bias is not defined at u1
// instead of using the default value of the port.

module wc_add (input var int a, input var int b, input var int bias = 7, output int sum);
  assign sum = a + b + bias;
endmodule

interface wc_if (input var int a, input var int k);
  int prod;
  assign prod = a * k;
endinterface

module test_wildcard_port_connection_once_any_position;
  int a = 1, b = 2, alt = 50;
  int s1, s2, s3;

  wc_add u1 (.*, .sum(s1));
  wc_add u2 (.b(alt), .*, .sum(s2));
  wc_add u3 (.sum(s3), .bias(1000), .*);
  wc_if wi (.k(alt), .*);

  initial #1 $display("s1=%0d s2=%0d s3=%0d prod=%0d", s1, s2, s3, wi.prod);
endmodule
