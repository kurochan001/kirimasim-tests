/*
:name: test_user_nettype_switch_and_driver_strength
:description: nets of a user-defined nettype ignore the strengths of their drivers and resolve with their resolution function, and tran and tranif1 between such nets join them into one net while on and are off for an x or z control (IEEE 1800-2023 Sections 28.8 and 28.12)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 28.12 4.9.5 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_user_nettype_switch_and_driver_strength.expected
*/
// IEEE 1800-2023 §28.12: nets of a user-defined nettype have no strength
// levels; the strengths of their drivers are ignored and the values are
// combined by the resolution function of the nettype (6.6.7). §28.8: tran,
// tranif0 and tranif1 can connect such nets, without any strength
// reduction, and for them a switch is off while its control is x or z.
// §4.9.5: while the switch is off each net is resolved on its own, and
// while it is on the two are resolved as one net. sum_t adds the values of
// all its drivers, and or_t takes the or of them. a has the drivers 3 and
// 4 and b the driver 10, joined by a tranif1 with the control c; p and q
// have the drivers 1 and 2, joined by a tran. n has a strong 0 driver and a
// weak 1 driver, which on a wire would give 0 but here give the or, 1; u
// and v have the same two drivers, one on each side of a tran.
// Icarus Verilog 13.0 and Verilator 5.052 do not support user-defined
// nettypes.

module test_user_nettype_switch_and_driver_strength;
  function automatic int f_sum(input int d[]);
    f_sum = 0;
    foreach (d[i]) f_sum += d[i];
  endfunction
  function automatic logic f_or(input logic d[]);
    f_or = 1'b0;
    foreach (d[i]) f_or |= d[i];
  endfunction
  nettype int sum_t with f_sum;
  nettype logic or_t with f_or;

  sum_t a, b, p, q;
  assign a = 3;
  assign a = 4;
  assign b = 10;
  assign p = 1;
  assign q = 2;
  logic c;
  tranif1 g_ab(a, b, c);
  tran g_pq(p, q);

  or_t n, u, v;
  assign (strong0, strong1) n = 1'b0;
  assign (weak0, weak1) n = 1'b1;
  assign (strong0, strong1) u = 1'b0;
  assign (weak0, weak1) v = 1'b1;
  tran g_uv(u, v);

  logic vals[4] = '{1'b1, 1'b0, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++) begin
      c = vals[i];
      #1 $display("c=%b: a=%0d b=%0d", c, a, b);
    end
    $display("tran: p=%0d q=%0d", p, q);
    $display("strong 0 and weak 1: n=%b", n);
    $display("strong 0 and weak 1 across a tran: u=%b v=%b", u, v);
  end
endmodule
