/*
:name: test_constraint_foreach_scope_dimensions
:description: A foreach constraint loop variable has the construct as its scope and the type of the array index, an empty loop variable stops the iteration over its dimension, trailing loop variables and commas can be omitted, and indices may use state variables while out-of-bounds ones need a predicate (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_foreach_scope_dimensions.expected
*/
// IEEE 1800-2023 §18.5.7.1: the loop variable of a foreach constraint belongs
// to the construct, so i in c_a is the index 0 to 3 and not the property i,
// which stays 100. foreach(cube[p, , r]) iterates over the first and third
// dimensions while the empty second variable stops iteration there;
// foreach(t3[q, s]) is the shorthand for [q, s, ,] and fixes the third index.
// An index may also be a state variable (arr[k]); an out-of-bounds index is
// not removed automatically, so a predicate has to guard it: with m == 5,
// (m < 4) -> arr[m] == 9 is eliminated before arr[m] is evaluated.

class fs_obj;
  rand int a[4];
  int i = 100;
  constraint c { foreach (a[i]) a[i] == i; }
endclass

class fd_obj;
  rand bit [3:0] cube[2][3][4];
  rand bit [3:0] t3[2][3][2];
  constraint c_cube { foreach (cube[p, , r]) cube[p][1][r] == p + r; }
  constraint c_t3 { foreach (t3[q, s]) t3[q][s][1] == q * 3 + s; }
endclass

class fi_obj;
  rand int arr[4];
  int k = 2;
  int m = 5;
  constraint c_k { arr[k] == 7; }
  constraint c_guard { (m < 4) -> arr[m] == 9; }
endclass

module test_constraint_foreach_scope_dimensions;
  fs_obj os = new;
  fd_obj od = new;
  fi_obj oi = new;
  int sfail, dfail, icube, it3, ifail;

  initial begin
    sfail = 0;
    repeat (50) begin
      if (!os.randomize()) sfail++;
      foreach (os.a[j]) if (os.a[j] != j) sfail++;
    end
    $display("loop variable scope: failures %0d, property i %0d", sfail, os.i);
    dfail = 0;
    icube = 1;
    it3 = 1;
    repeat (50) begin
      if (!od.randomize()) dfail++;
      for (int p = 0; p < 2; p++)
        for (int r = 0; r < 4; r++)
          if (od.cube[p][1][r] != p + r) icube = 0;
      for (int q = 0; q < 2; q++)
        for (int s = 0; s < 3; s++)
          if (od.t3[q][s][1] != q * 3 + s) it3 = 0;
    end
    $display("dimensions: failures %0d, empty middle %0d, trailing omitted %0d",
             dfail, icube, it3);
    ifail = 0;
    repeat (50) begin
      if (!oi.randomize()) ifail++;
      if (oi.arr[2] != 7) ifail++;
    end
    $display("state index: failures %0d, arr[2] stays 7 %0d",
             ifail, oi.arr[2] == 7);
  end
endmodule
