/*
:name: test_cg_auto_bins_two_state
:description: Automatic bins cover only 2-state values, so a sampled value with an x or z bit hits no automatic bin (IEEE 1800-2023 Section 19.5.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.3 19.8
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cg_auto_bins_two_state.expected
*/
// IEEE 1800-2023 §19.5.3: automatically created bins only consider 2-state
// values; sampled values that contain x or z are excluded. The 2-bit logic v
// has the 4 automatic bins of the values 0 to 3. The samples 2'bx0, 2'b1z and
// 2'bzx hit none of them, 2'b10 hits one, and 2'b0x after it hits none.
// get_inst_coverage(c, t) gives the covered bins and the bins (19.8).

module test_cg_auto_bins_two_state;
  logic [1:0] v;

  covergroup cg;
    cp: coverpoint v;
  endgroup

  cg g = new;

  task automatic put(logic [1:0] x);
    int c, t;
    v = x;
    g.sample();
    void'(g.cp.get_inst_coverage(c, t));
    $display("v=%b: %0d/%0d", x, c, t);
  endtask

  initial begin
    put(2'bx0);
    put(2'b1z);
    put(2'bzx);
    put(2'b10);
    put(2'b0x);
  end
endmodule
