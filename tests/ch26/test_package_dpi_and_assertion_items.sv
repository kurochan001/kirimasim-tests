/*
:name: test_package_dpi_and_assertion_items
:description: a package holds a DPI import and a DPI export, a let, a sequence and a property, and a module calls the import, which calls the export, and asserts and covers the package property and sequence (IEEE 1800-2023 Sections 26.2, A.1.11)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 A.1.11 35.5.3 11.12 16.8 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_package_dpi_and_assertion_items.c
:expected_stdout: @test_package_dpi_and_assertion_items.expected
*/
// IEEE 1800-2023 §26.2 and A.1.11: a package item can be a DPI import or
// export declaration and an assertion item declaration, that is, a property,
// a sequence or a let declaration. pk_dpi_assert declares
// - a context import c_scaled_sum, whose C side returns 10 times the result of
//   the exported package function sv_add (§35.5.3: a context import may call
//   an export of the scope of its declaration), so c_scaled_sum(2, 5) is 70;
// - a let max2 giving the larger of its two arguments (§11.12);
// - a sequence s_pulse(sig), sig ##1 !sig, and a property p_pulse_ack(sig,
//   ack), s_pulse(sig) |-> ack (§16.8, §16.12).
// The module samples req and ack at nine rising clock edges with the values of
// rq and ak below; s_pulse(req) matches at ticks 3, 6 and 9, where ack is 1,
// 0 and 1, so the cover statement succeeds three times and the assertion fails
// once. The inputs change midway between edges.

`timescale 1ns/1ns

package pk_dpi_assert;
  import "DPI-C" context function int c_scaled_sum(int a, int b);
  export "DPI-C" function sv_add;

  function int sv_add(int a, int b);
    return a + b;
  endfunction

  let max2(a, b) = (a > b) ? a : b;

  sequence s_pulse(sig);
    sig ##1 !sig;
  endsequence

  property p_pulse_ack(sig, ack);
    s_pulse(sig) |-> ack;
  endproperty
endpackage

module test_package_dpi_and_assertion_items;
  logic clk = 0, req = 0, ack = 0;
  int fails = 0, hits = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, ..., 85

  a_ack: assert property (@(posedge clk) pk_dpi_assert::p_pulse_ack(req, ack)) else fails++;
  c_pulse: cover property (@(posedge clk) pk_dpi_assert::s_pulse(req)) hits++;

  initial begin
    logic [1:9] rq = 9'b010010110, ak = 9'b001000001;

    $display("max2(3,7)=%0d max2(9,2)=%0d", pk_dpi_assert::max2(3, 7), pk_dpi_assert::max2(9, 2));
    $display("c_scaled_sum(2,5)=%0d", pk_dpi_assert::c_scaled_sum(2, 5));
    for (int k = 1; k <= 9; k++) begin
      req = rq[k];
      ack = ak[k];
      #10;
    end
    $display("fails=%0d hits=%0d", fails, hits);
    $finish;
  end
endmodule
