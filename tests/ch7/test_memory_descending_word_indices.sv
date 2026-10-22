/*
:name: test_memory_descending_word_indices
:description: A memory with negative descending indices retains independently addressed packed words (IEEE 1800-2023 Section 7.4.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_memory_descending_word_indices.expected
*/
// IEEE 1800-2023 7.4.3: An unpacked dimension indexes complete words; writes to
// one word or its part select leave the other word unchanged.

module test_memory_descending_word_indices;
  logic [11:0] mem[-1:-3];
  initial begin
    mem[-1] = 12'h123; mem[-2] = 12'h456; mem[-3] = 12'h789;
    mem[-2][7:4] = 4'ha;
    $display("words=%h,%h,%h width=%0d size=%0d", mem[-1], mem[-2], mem[-3],
             $bits(mem[-1]), $size(mem));
  end
endmodule
