/*
:name: test_cg_warn_negative_unsigned
:description: A bin value that is signed and negative for an unsigned coverpoint causes a warning and does not become part of the bin, while the other value of the same bin still covers its samples (IEEE 1800-2023 Section 19.5.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_warn_negative_unsigned.expected
:expected_stderr_regex: (?i)warn
*/
// IEEE 1800-2023 §19.5.7: a bin value b is cast to the effective type of the
// coverpoint expression, which is the unsigned 3-bit type of u. When the
// effective type is unsigned and b is signed with a negative value, an
// implementation shall issue a warning and the singleton value shall not
// participate in the bin. The bin bad therefore has no value and is not
// counted, while good holds 2, so the coverpoint has one bin. Sampling 2
// covers it; sampling 7 covers nothing.

module test_cg_warn_negative_unsigned;
  bit [2:0] u;

  covergroup cg;
    cp: coverpoint u {
      bins bad = {-1};
      bins good = {2};
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
    put(2);
    put(7);
  end
endmodule
