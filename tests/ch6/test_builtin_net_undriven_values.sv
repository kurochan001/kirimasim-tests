/*
:name: test_builtin_net_undriven_values
:description: Without drivers the built-in nets other than trireg are z, tri0 and tri1 are pull 0 and pull 1, supply0 and supply1 are supply 0 and supply 1 even against a strong driver, and a net whose only driver turns off goes back to z (IEEE 1800-2023 Section 6.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6 6.6.6 6.7.1 28.15.1 28.15.3 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_builtin_net_undriven_values.expected
*/
// IEEE 1800-2023 §6.6: a net does not store a value (trireg aside, see
// 6.6.4); its value comes from its drivers, and with no driver it is z.
// §6.7.1: a net starts as z until its drivers give it their values, apart from
// the nets with a source of their own: tri0 and tri1 have a pull 0 and a pull
// 1 on them (28.15.1), and supply0 and supply1 have supply strength (6.6.6,
// 28.15.3), which is stronger than any driver.
// One net of each built-in type except trireg is left undriven and shown with
// %v (21.2.1.4) at time 1. The supply nets sd0 and sd1 also have a strong
// driver of the other value, which they override. The wire g is driven by a
// bufif1 that is turned off, and it goes back to z instead of keeping the 1 it
// had.

module test_builtin_net_undriven_values;
  wire w;
  tri t;
  wand wa;
  triand ta;
  wor wo;
  trior tr;
  uwire u;
  tri0 t0;
  tri1 t1;
  supply0 s0;
  supply1 s1;
  supply0 sd0;
  supply1 sd1;
  logic one = 1'b1, zero = 1'b0, en = 1'b1;
  wire g;

  assign sd0 = one;
  assign sd1 = zero;
  bufif1 drv(g, one, en);

  initial begin
    #1 $display("undriven: wire=%v tri=%v wand=%v triand=%v wor=%v trior=%v uwire=%v",
                w, t, wa, ta, wo, tr, u);
    $display("own source: tri0=%v tri1=%v supply0=%v supply1=%v", t0, t1, s0, s1);
    $display("against strong: supply0=%v supply1=%v", sd0, sd1);
    $display("driver on: g=%b %v", g, g);
    en = 1'b0;
    #1 $display("driver off: g=%b %v", g, g);
  end
endmodule
