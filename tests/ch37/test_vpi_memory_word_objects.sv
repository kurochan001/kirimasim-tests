/*
:name: test_vpi_memory_word_objects
:description: The vpiMemory relation of a module and of a named block returns their one-dimensional reg arrays as objects of type vpiRegArray, and vpiMemoryWord returns the words as vpiReg objects with their index, range, value and the array as parent (IEEE 1800-2023 Section 37.20)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.20 37.10 37.12 37.17 38.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_memory_word_objects.c
:expected_stdout: @test_vpi_memory_word_objects.expected
*/
// IEEE 1800-2023 §37.20: vpiMemory and vpiMemoryWord are kept as methods that
// return objects of type vpiRegArray and vpiReg (detail 1; §37.10 detail 4):
// vpi_iterate(vpiMemory) over the module gives mem, and over the named block
// blk, a scope (37.12), gives pair; the plain vector r is no memory. mem has
// the range 1:3 and size 3 (37.17 detail 9). vpi_iterate(vpiMemoryWord, mem)
// gives its three words, named with their index (37.17 detail 28); the word
// mem[2] is 8 bits wide with range 7:0, its vpiIndex is 2, its vpiParent is
// mem, and vpi_handle_by_index (38.19) gives the same word. Lists are sorted.
//
// Icarus Verilog 13.0 gives the array the type vpiMemory and its words the
// type vpiMemoryWord, and numbers the indices of the words from 0, so its
// word with index 2 is mem[3].

module test_vpi_memory_word_objects;
  reg [7:0] mem [1:3];
  reg [3:0] r;

  initial begin : blk
    reg [1:0] pair [2:0];
    pair[0] = 2'd1;
    r = 4'h6;
    mem[1] = 8'h11;
    mem[2] = 8'h22;
    mem[3] = 8'h33;
    #1 $vt_memory;
  end
endmodule
