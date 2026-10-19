/*
:name: test_randc_full_cycle
:description: A randc variable returns every value of its range once before any value repeats (IEEE 1800-2023 Section 18.4.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randc_full_cycle.expected
*/
// IEEE 1800-2023 §18.4.2: a randc variable goes through a random permutation of
// all the values of its range, one value per call of randomize(), and starts a
// new permutation after the last one. So each group of 8 calls for a 3-bit
// randc variable gives each of the 8 values exactly once, while the order is
// random.

class rcc_obj;
  randc bit [2:0] r;
endclass

module test_randc_full_cycle;
  rcc_obj o;
  bit [7:0] seen;
  int repeats = 0;
  int incomplete = 0;

  initial begin
    o = new;
    repeat (4) begin
      seen = 0;
      repeat (8) begin
        void'(o.randomize());
        if (seen[o.r]) repeats++;
        seen[o.r] = 1'b1;
      end
      if (seen != 8'hFF) incomplete++;
    end
    $display("4 cycles of 8: repeated values=%0d incomplete cycles=%0d", repeats, incomplete);
  end
endmodule
