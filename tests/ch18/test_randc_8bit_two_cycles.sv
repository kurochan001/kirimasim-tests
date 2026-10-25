/*
:name: test_randc_8bit_two_cycles
:description: An 8-bit randc variable is supported in full: each run of 256 randomize() calls gives each of its 256 values exactly once (IEEE 1800-2023 Section 18.4.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randc_8bit_two_cycles.expected
*/
// IEEE 1800-2023 §18.4.2: a tool may limit the size of a randc variable, but
// the limit shall be at least 8 bits. A randc variable runs through a random
// permutation of all values of its range, one value per randomize() call,
// and starts a new permutation after the last value. So an 8-bit randc
// variable gives each of its 256 values exactly once in calls 1 to 256 and
// again in calls 257 to 512, and no value repeats within either run. A tool
// that treated the 8-bit variable like rand (or cycled only through part of
// the range) would repeat values and miss others.
// Icarus Verilog 13.0 does not compile randomize().

class r8c_obj;
  randc bit [7:0] v;
endclass

module test_randc_8bit_two_cycles;
  r8c_obj o;
  bit seen [256];
  int ok, repeats, missing;

  initial begin
    o = new;
    for (int cycle = 1; cycle <= 2; cycle++) begin
      foreach (seen[i]) seen[i] = 0;
      ok = 1;
      repeats = 0;
      missing = 0;
      repeat (256) begin
        ok &= o.randomize();
        if (seen[o.v]) repeats++;
        seen[o.v] = 1;
      end
      foreach (seen[i]) if (!seen[i]) missing++;
      $display("cycle %0d: all calls succeeded=%0d repeated=%0d missing=%0d", cycle, ok, repeats,
               missing);
    end
  end
endmodule
