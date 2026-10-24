/*
:name: test_wired_net_resolution_tables
:description: Two equal-strength drivers on wand, triand, wor and trior nets resolve by the wired-AND and wired-OR tables for all 16 pairs of 0, 1, x and z (IEEE 1800-2023 Section 6.6.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wired_net_resolution_tables.expected
*/
// IEEE 1800-2023 §6.6.3: wand and triand are one net type under two names, and
// so are wor and trior. On a wand or triand net a 0 from either driver gives
// 0; otherwise an x gives x, a z gives way to the other driver, and 1 with 1
// gives 1. On a wor or trior net a 1 from either driver gives 1; otherwise an
// x gives x, a z gives way to the other driver, and 0 with 0 gives 0. Each of
// the four nets has two continuous assignments of the same (default strong)
// strength from a and b, and every pair of 0, 1, x and z is driven in both
// orders, so each line shows one entry of both tables for both names.

module test_wired_net_resolution_tables;
  logic a, b;
  logic [3:0] vals = 4'bzx10;   // vals[0..3] = 0, 1, x, z
  wand wa;
  triand ta;
  wor wo;
  trior to;

  assign wa = a;
  assign wa = b;
  assign ta = a;
  assign ta = b;
  assign wo = a;
  assign wo = b;
  assign to = a;
  assign to = b;

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) begin
        a = vals[i];
        b = vals[j];
        #1 $display("%b%b wand=%b triand=%b wor=%b trior=%b", a, b, wa, ta, wo, to);
      end
  end
endmodule
