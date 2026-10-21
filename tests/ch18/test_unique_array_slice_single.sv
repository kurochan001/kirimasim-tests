/*
:name: test_unique_array_slice_single
:description: A unique constraint applies to the leaf elements of a whole unpacked array, of a multidimensional array and of a slice, and a group with one member has no effect (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_array_slice_single.expected
*/
// IEEE 1800-2023 §18.5.4: the members of a unique group are its singular
// variables and the leaf elements of the arrays and slices it names, and no
// two of them get the same value. So the 16 elements of perm, 4-bit values,
// are each value once; the 4 leaf elements of the 2x2 array g, 2-bit values,
// are each value once; and the slice w[1:3] with p are 4 different values,
// all in [9:12], so they are 9, 10, 11 and 12 in some order. w[0] is not in
// the group and is equal to w[1]. A group with fewer than two members,
// unique {solo}, has no effect and causes no contradiction.

class uas_obj;
  rand bit [3:0] perm[16];
  rand bit [1:0] g[2][2];
  rand bit [3:0] w[4];
  rand bit [3:0] p, solo;
  constraint c_perm { unique {perm}; }
  constraint c_g { unique {g}; }
  constraint c_slice {
    unique {w[1:3], p};
    p inside {[9:12]};
    foreach (w[i]) if (i > 0) w[i] inside {[9:12]};
    w[0] == w[1];
  }
  constraint c_solo { unique {solo}; solo == 4'd3; }
endclass

module test_unique_array_slice_single;
  uas_obj o;
  int failed = 0;
  int bad_perm = 0, bad_g = 0, bad_slice = 0, bad_solo = 0;
  bit [15:0] seen16;
  bit [3:0] seen4;
  bit [15:0] seen_s;

  initial begin
    o = new;
    repeat (20) begin
      if (!o.randomize()) failed++;
      seen16 = 0;
      foreach (o.perm[i]) seen16[o.perm[i]] = 1'b1;
      if (seen16 != 16'hFFFF) bad_perm++;
      seen4 = 0;
      foreach (o.g[i, j]) seen4[o.g[i][j]] = 1'b1;
      if (seen4 != 4'hF) bad_g++;
      seen_s = 0;
      seen_s[o.p] = 1'b1;
      for (int i = 1; i < 4; i++) seen_s[o.w[i]] = 1'b1;
      if (seen_s != 16'h1E00 || o.w[0] != o.w[1]) bad_slice++;
      if (o.solo != 4'd3) bad_solo++;
    end
    $display("20 calls: failed=%0d", failed);
    $display("violations: perm=%0d g=%0d slice=%0d solo=%0d", bad_perm, bad_g, bad_slice, bad_solo);
  end
endmodule
