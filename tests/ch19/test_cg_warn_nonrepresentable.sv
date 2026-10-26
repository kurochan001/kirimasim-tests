/*
:name: test_cg_warn_nonrepresentable
:description: A bin value whose assignment to the effective type of the coverpoint changes it causes a warning and does not become part of the bin, so the other value of the bin still works (IEEE 1800-2023 Section 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_warn_nonrepresentable.expected
:expected_stderr_regex: (?i)warn
*/
// IEEE 1800-2023 §19.5.7: b shall be cast to the effective type of the
// coverpoint expression. The unsigned 3-bit type of u cannot express 8: the
// cast gives 0, which is not equal to 8 under the normal == comparison, so a
// warning shall be issued and the singleton value shall not participate in
// the bin. The bin bad therefore has no value and is not counted, while good
// holds 7, so the coverpoint has one bin. Sampling 7 covers it; sampling 0,
// which would equal the cast value if 8 stayed, does not.

module test_cg_warn_nonrepresentable;
  bit [2:0] u;

  covergroup cg;
    cp: coverpoint u {
      bins bad = {8};
      bins good = {7};
    }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] v);
    int c, t;
    u = v;
    g.sample();
    void'(g.cp.get_inst_coverage(c, t));
    $display("u=%0d: %0d/%0d", v, c, t);
  endtask

  initial begin
    put(7);
    put(0);
  end
endmodule
