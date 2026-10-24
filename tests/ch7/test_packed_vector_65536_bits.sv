/*
:name: test_packed_vector_65536_bits
:description: a packed array of 65536 bits, the least maximum size a tool has to allow, can be declared, selected at both ends and used in arithmetic over its full width (IEEE 1800-2023 Section 7.4.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_vector_65536_bits.expected
*/
// IEEE 1800-2023 §7.4.1: a tool may limit the size of a packed array, but the
// limit shall be at least 65536 (2**16) bits. v has exactly that many bits.
// The test sets its top, middle and bottom bits, counts them, reads the top
// bits with a part-select and a shift, and adds 1 to a vector of all ones,
// whose carry has to run through all 65536 bits.

module test_packed_vector_65536_bits;
  bit [65535:0] v, ones;
  int low;

  initial begin
    v = '0;
    v[65535] = 1'b1;
    v[32768] = 1'b1;
    v[0] = 1'b1;
    low = v >> 65535;
    $display("bits=%0d ones=%0d top4=%b top>>65535=%0d", $bits(v), $countones(v),
             v[65535 -: 4], low);
    ones = '1;
    $display("all ones: count=%0d", $countones(ones));
    ones = ones + 1'b1;
    $display("all ones + 1: zero=%0d", ones == '0);
  end
endmodule
