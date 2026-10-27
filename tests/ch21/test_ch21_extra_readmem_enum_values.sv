/*
:name: test_ch21_extra_readmem_enum_values
:description: $readmemh loads an enumerated memory array from the numeric values in the file, so the words compare equal to the enumeration elements with those values (IEEE 1800-2023 Section 21.4.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.2 21.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch21_extra_readmem_enum_values.expected
*/
// IEEE 1800-2023 §21.4.2: "$readmemb and $readmemh support packed data of
// 2-state types, such as int or enumerated types. ... For enumerated types,
// the file data represents the numeric values associated with each element
// of the enumerated type (see 6.19)." The test writes the hexadecimal words
// 0, 1 and 2, loads them into a four-word array whose element type is an
// enumeration with RED = 0, GREEN = 1 and BLUE = 2, and prints whether each
// loaded word equals the element with that numeric value. The fourth word
// was not written by the file and keeps its initial value.
//
// The second sentence of the clause, which requires an error and no further
// reading when a numeric value is out of range for the type, is not
// exercised: both simulators truncate such a word to the width of the base
// type and continue with the next word, and the clause does not give the
// text of the error, so there is no expected output that the standard fixes.

module test_ch21_extra_readmem_enum_values;
  typedef enum logic [2:0] {RED = 0, GREEN = 1, BLUE = 2} color_t;

  localparam string FILE = "test_ch21_extra_readmem_enum_values.mem";
  color_t mem[0:3];
  int fd;

  initial begin
    fd = $fopen(FILE, "w");
    $fdisplay(fd, "0 1 2");
    $fclose(fd);
    foreach (mem[i]) mem[i] = RED;
    $readmemh(FILE, mem);
    $display("word0 is RED: %0d", mem[0] == RED);
    $display("word1 is GREEN: %0d", mem[1] == GREEN);
    $display("word2 is BLUE: %0d", mem[2] == BLUE);
    $display("word3 keeps its value: %0d", mem[3] == RED);
  end
endmodule
