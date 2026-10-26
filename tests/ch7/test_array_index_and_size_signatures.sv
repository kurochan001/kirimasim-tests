/*
:name: test_array_index_and_size_signatures
:description: an invalid array index reads the default value and writes nothing, a warning is optional, and dynamic-array size returns int without arguments
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 7.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_index_and_size_signatures.expected
*/
// IEEE 1800-2023 7.4.5: reading an unpacked array with an out-of-bounds
// index returns the Table 7-1 value of the element type, writing performs no
// operation, and an implementation may issue a warning but is not required to.
// 7.5.2: size() takes no argument and returns int. The test reads and writes
// a fixed int array at index 5: the read is 0, the write leaves a[0] alone,
// and the run continues, so a tool that makes the invalid index an error
// fails while one that warns or stays silent both pass. $bits(d.size()) is 32
// for the int return of the dynamic-array size method.

module test_array_index_and_size_signatures;
  int a[2] = '{10, 20};
  int d[] = new[3];
  int r;

  initial begin
    d[0] = 1;
    d[1] = 2;
    d[2] = 3;
    r = a[5];
    a[5] = 99;
    $display("read=%0d fixed_size=%0d a0=%0d", r, $size(a), a[0]);
    $display("dyn=%0d dyn_bits=%0d dyn_oob=%0d", d.size(), $bits(d.size()), d[3]);
  end
endmodule
