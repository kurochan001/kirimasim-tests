/*
:name: test_constraint_implication_ifelse
:description: Implication and if-else constraints, alone and with an inline constraint that fixes the condition (IEEE 1800-2023 Section 18.5.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.5 18.5.6 18.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_implication_ifelse.expected
*/
// IEEE 1800-2023 §18.5.5: mode -> v == 9 requires v to be 9 whenever mode is 1
// and says nothing otherwise. §18.5.6: if (v > 8) w < 3; else w > 12; applies
// one of the two constraints depending on v. With randomize() with
// { mode == 1; } (18.7) the condition is fixed, so v is always 9 and w always
// below 3.

class cie_obj;
  rand bit mode;
  rand bit [3:0] v;
  rand bit [3:0] w;
  constraint c_imp { mode -> v == 4'd9; }
  constraint c_ife { if (v > 8) w < 3; else w > 12; }
endclass

module test_constraint_implication_ifelse;
  cie_obj o;
  int bad = 0;
  int forced_bad = 0;

  initial begin
    o = new;
    repeat (200) begin
      void'(o.randomize());
      if (o.mode && o.v != 4'd9) bad++;
      if (o.v > 8 && !(o.w < 3)) bad++;
      if (o.v <= 8 && !(o.w > 12)) bad++;
    end
    repeat (50) begin
      void'(o.randomize() with { mode == 1; });
      if (o.v != 4'd9 || !(o.w < 3)) forced_bad++;
    end
    $display("violations=%0d, with mode==1: violations=%0d", bad, forced_bad);
  end
endmodule
