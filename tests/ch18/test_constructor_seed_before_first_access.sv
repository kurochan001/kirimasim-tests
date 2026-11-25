/*
:name: test_constructor_seed_before_first_access
:description: An object seeds its RNG before a different process first accesses it
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.14.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constructor_seed_before_first_access.expected
*/
`timescale 1ns/1ns
module test_constructor_seed_before_first_access;
  class generator;
    rand bit [15:0] value;
    function new(int seed);
      this.srandom(seed);
    endfunction
  endclass

  generator published;
  bit ready;

  initial begin
    void'($urandom);
    #3 published = new(810);
    ready = 1;
  end

  initial begin
    generator independently_created;
    bit same_samples;
    same_samples = 1;
    independently_created = new(810);
    wait (ready);
    repeat (3) begin
      if (!published.randomize() || !independently_created.randomize())
        $fatal(1, "randomize failed");
      same_samples &= published.value == independently_created.value;
    end
    $display("first access t=%0d constructor-seeded replay=%0d", $time, same_samples);
    $finish(0);
  end
endmodule
