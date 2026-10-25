/*
:name: test_randc_static_shared_cycle
:description: The randc state of a static randc variable is static too: randomize() calls through different instances of the base class and of a derived class take the next values of one shared permutation (IEEE 1800-2023 Section 18.4.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.2 18.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randc_static_shared_cycle.expected
*/
// IEEE 1800-2023 §18.4.2: when a random variable is declared static, its
// randc state is also static, so randomize() picks the next cyclic value of
// one single sequence whichever instance of the base class it is called
// through. §18.6.3: the static variable itself is shared by all instances.
// s is a static randc 3-bit variable of rsc_base; a is an rsc_base object
// and b an object of the derived class rsc_derived. Calls alternate a, b,
// a, b, ...: each group of 8 calls (4 through a, 4 through b) takes the 8
// values of one permutation, so no value repeats within a group, and s
// read through the other handle shows the value just chosen. With one
// permutation per object, the values of a group would all differ in only
// 1 of 70 cases, and 6 groups give 3 such independent chances.
// Icarus Verilog 13.0 does not compile randomize(). Verilator 5.052 keeps a
// separate permutation for each object, so values repeat within groups.

class rsc_base;
  static randc bit [2:0] s;
endclass

class rsc_derived extends rsc_base;
endclass

module test_randc_static_shared_cycle;
  rsc_base a;
  rsc_derived b;
  bit [7:0] seen;
  int ok = 1, repeats = 0, missing = 0, mismatch = 0;

  initial begin
    a = new;
    b = new;
    repeat (6) begin
      seen = 0;
      repeat (4) begin
        ok &= a.randomize();
        if (b.s != a.s) mismatch++;
        if (seen[a.s]) repeats++;
        seen[a.s] = 1'b1;
        ok &= b.randomize();
        if (a.s != b.s) mismatch++;
        if (seen[b.s]) repeats++;
        seen[b.s] = 1'b1;
      end
      foreach (seen[i]) if (!seen[i]) missing++;
    end
    $display("6 groups of 8 calls: ok=%0d repeated=%0d missing=%0d not shared=%0d", ok, repeats,
             missing, mismatch);
  end
endmodule
