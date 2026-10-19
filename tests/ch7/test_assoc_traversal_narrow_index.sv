/*
:name: test_assoc_traversal_narrow_index
:description: An associative array traversal method given an index variable too narrow for the key returns -1 and keeps the low bits of the key (IEEE 1800-2023 Section 7.9.8)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9.8 7.9.4 7.9.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_traversal_narrow_index.expected
*/
// IEEE 1800-2023 §7.9.8: first(), last(), next() and prev() write the index
// they find into their argument. When the argument is an integral variable
// narrower than the index type and the key does not fit, the method returns -1
// and the argument gets the low bits of the key. With a variable as wide as the
// index type, first() (7.9.4) and last() (7.9.5) return 1 and the whole key.
//
// An index variable narrower than the index type is not supported by version
// 5.052 of Verilator, and Icarus Verilog 13.0 does not compile this test.

module test_assoc_traversal_narrow_index;
  int aa[int];
  bit [7:0] narrow;
  int wide;
  int status;

  initial begin
    aa[1000] = 1;
    aa[2000] = 2;
    status = aa.first(narrow);
    $display("first into 8 bits: status=%0d index=%0d", status, narrow);
    status = aa.last(narrow);
    $display("last into 8 bits: status=%0d index=%0d", status, narrow);
    status = aa.first(wide);
    $display("first into int: status=%0d index=%0d", status, wide);
    status = aa.last(wide);
    $display("last into int: status=%0d index=%0d", status, wide);
  end
endmodule
