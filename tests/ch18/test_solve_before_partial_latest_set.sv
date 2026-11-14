/*
:name: test_solve_before_partial_latest_set
:description: a variable ordered after x and before z is solved together with y, the set between them, and a variable ordered only after x is solved with z, the last set, as the probabilities of constraints that couple each of them to its set show (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_partial_latest_set.expected
*/
// IEEE 1800-2023 §18.5.9: a partially ordered variable is solved with the
// latest set of ordered variables that still meets all its ordering
// constraints, and within one set all legal combinations are equally likely;
// a set solved earlier has its values chosen first, each value that has a
// legal completion equally likely. In plg_obj the chain x, y, z makes the
// sets {x}, {y} and {z}. v is ordered after x and before z, so the latest set
// it can join is that of y; w is ordered only after x, so it joins z.
// The 8-bit pairs are coupled by y[0] -> v == 0 and v[7] -> y == 0, and the
// same for z and w. Solved together, 16640 pairs (y, v) are legal and y[0]
// is 1 in 128 of them and v[7] in 128, under 1%. If v were solved before y,
// v would be uniform and v[7] would be 1 half of the time; if after y, y[0]
// would be 1 half of the time. The same holds for z and w. In 200 calls each
// count stays under 20 (10%) when the pair is solved together, and it is
// above 20 when it is not, except with negligible probability. plg_ctl adds
// solve v before y, so there v[7] is 1 about half of the time while y[0]
// stays rare; it shows that the counts see the order.
// Icarus Verilog 13.0 does not support constraints. The 5.054 release of
// the Verilator simulator does not give these probabilities: in a run with
// seed 1, y[0] of plg_obj was 1 in 58 of the 200 calls and v[7] of plg_ctl
// was never 1.

class plg_obj;
  rand bit x;
  rand bit [7:0] y, z, v, w;
  constraint c_vy { y[0] -> v == 0; v[7] -> y == 0; }
  constraint c_wz { z[0] -> w == 0; w[7] -> z == 0; }
  constraint c_order {
    solve x before y;
    solve y before z;
    solve x before v;
    solve v before z;
    solve x before w;
  }
endclass

class plg_ctl;
  rand bit x;
  rand bit [7:0] y, z, v, w;
  constraint c_vy { y[0] -> v == 0; v[7] -> y == 0; }
  constraint c_wz { z[0] -> w == 0; w[7] -> z == 0; }
  constraint c_order {
    solve x before y;
    solve y before z;
    solve x before v;
    solve v before z;
    solve x before w;
    solve v before y;
  }
endclass

module test_solve_before_partial_latest_set;
  plg_obj o = new;
  plg_ctl c = new;
  int fails, ny0, nv7, nz0, nw7;
  int cfails, cy0, cv7;

  initial begin
    repeat (200) begin
      if (!o.randomize()) fails++;
      else begin
        if (o.y[0]) ny0++;
        if (o.v[7]) nv7++;
        if (o.z[0]) nz0++;
        if (o.w[7]) nw7++;
      end
      if (!c.randomize()) cfails++;
      else begin
        if (c.y[0]) cy0++;
        if (c.v[7]) cv7++;
      end
    end
    $display("failures %0d", fails);
    $display("v with the set of y: y[0] under 10%% %0d, v[7] under 10%% %0d", ny0 < 20, nv7 < 20);
    $display("w with the set of z: z[0] under 10%% %0d, w[7] under 10%% %0d", nz0 < 20, nw7 < 20);
    $display("solve v before y added: failures %0d, y[0] under 10%% %0d, v[7] under 10%% %0d",
             cfails, cy0 < 20, cv7 < 20);
  end
endmodule
