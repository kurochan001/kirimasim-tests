/*
:name: test_unpacked_array_16777216_elements
:description: an unpacked array of 16777216 elements, the least maximum size a tool has to allow, can be declared and its first and last elements written and read (IEEE 1800-2023 Section 7.4.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_array_16777216_elements.expected
*/
// IEEE 1800-2023 §7.4.2: a tool may limit the size of an array, but it shall
// allow at least 16777216 (2**24) elements. mem has exactly that many 1-bit
// elements, declared with a size, which means [0:16777215]. The test writes
// the first, a middle and the last element and reads them and their
// neighbours back, and $size (§20.7) shows the number of elements.

module test_unpacked_array_16777216_elements;
  bit mem [16777216];

  initial begin
    mem[0] = 1'b1;
    mem[8388608] = 1'b1;
    mem[16777215] = 1'b1;
    $display("size=%0d", $size(mem));
    $display("first=%b second=%b middle=%b last=%b before last=%b",
             mem[0], mem[1], mem[8388608], mem[16777215], mem[16777214]);
  end
endmodule
