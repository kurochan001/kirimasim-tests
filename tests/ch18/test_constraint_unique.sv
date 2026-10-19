/*
:name: test_constraint_unique
:description: A unique constraint gives every variable of the group a different value (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_unique.expected
*/
// IEEE 1800-2023 §18.5.4: unique { ... } requires all the variables listed to
// have different values after randomization. Seven 3-bit variables can take
// only seven of the eight values, with no two equal.

class cu_obj;
  rand bit [2:0] s, t, u, v, w, x, y;
  constraint c { unique {s, t, u, v, w, x, y}; }
endclass

module test_constraint_unique;
  cu_obj o;
  bit [2:0] vals[7];
  int dup = 0;
  int failed = 0;

  initial begin
    o = new;
    repeat (100) begin
      if (!o.randomize()) failed++;
      vals = '{o.s, o.t, o.u, o.v, o.w, o.x, o.y};
      foreach (vals[i])
        for (int j = i + 1; j < 7; j++)
          if (vals[i] == vals[j]) dup++;
    end
    $display("failed=%0d equal pairs=%0d", failed, dup);
  end
endmodule
