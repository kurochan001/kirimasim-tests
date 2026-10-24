/*
:name: test_tri0_tri1_resolution_tables
:description: Two strong drivers on a tri0 and a tri1 net resolve by their tables for all 16 pairs of 0, 1, x and z, with strong strength unless both are z, and single weak or pull drivers combine with the implicit pull value (IEEE 1800-2023 Section 6.6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.5 28.12 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tri0_tri1_resolution_tables.expected
*/
// IEEE 1800-2023 §6.6.5: a tri0 net acts as a wire with a continuous pull 0 on
// it and a tri1 net as a wire with a continuous pull 1, and its drivers combine
// with that pull value. With two strong drivers the tables give: equal values
// give that value, 0 with 1 or anything with x gives x, a z gives way to the
// other driver, and two z give 0 on tri0 and 1 on tri1. The result has strong
// strength except when both drivers are z, where it is the pull value.
// n0 and n1 have two strong continuous assignments from a and b, and every
// pair of 0, 1, x and z is driven in both orders; %v (21.2.1.4) shows the
// strength and value. Then single drivers from c show the combination with the
// implicit pull (28.12): a weak driver loses to it (We1 on tri0 gives Pu0), and
// a pull driver of the other value ties with it and gives PuX.

module test_tri0_tri1_resolution_tables;
  logic a, b, c;
  logic [3:0] vals = 4'bzx10;   // vals[0..3] = 0, 1, x, z
  tri0 n0;
  tri1 n1;
  tri0 w0;
  tri1 w1;
  tri0 p0;
  tri1 p1;

  assign n0 = a;
  assign n0 = b;
  assign n1 = a;
  assign n1 = b;
  assign (weak0, weak1) w0 = c;
  assign (weak0, weak1) w1 = c;
  assign (pull0, pull1) p0 = c;
  assign (pull0, pull1) p1 = c;

  initial begin
    for (int i = 0; i < 4; i++)
      for (int j = 0; j < 4; j++) begin
        a = vals[i];
        b = vals[j];
        #1 $display("%b%b tri0=%b %v tri1=%b %v", a, b, n0, n0, n1, n1);
      end
    c = 1'b0;
    #1 $display("c=%b weak: tri0=%v tri1=%v pull: tri0=%v tri1=%v", c, w0, w1, p0, p1);
    c = 1'b1;
    #1 $display("c=%b weak: tri0=%v tri1=%v pull: tri0=%v tri1=%v", c, w0, w1, p0, p1);
    c = 1'bz;
    #1 $display("c=%b weak: tri0=%v tri1=%v pull: tri0=%v tri1=%v", c, w0, w1, p0, p1);
  end
endmodule
