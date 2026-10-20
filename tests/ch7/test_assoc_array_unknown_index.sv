/*
:name: test_assoc_array_unknown_index
:description: An index with x or z bits is invalid for an associative array: a read gives the element type's default and a write does nothing (IEEE 1800-2023 Section 7.8.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.6 7.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assoc_array_unknown_index.expected
*/
// IEEE 1800-2023 §7.8.6: when the index of an associative array read is a
// 4-state expression with an x or z bit, the read gives the value of a
// nonexistent entry, which is the default of the element type (Table 7-1,
// 'x for logic [7:0]); the index is not converted to 0 even when the array
// is indexed by int. A write with such an index is ignored. A simulator may
// also warn about either.

module test_assoc_array_unknown_index;
  logic [7:0] aa[int];
  logic [2:0] idx;
  logic [7:0] r;

  initial begin
    aa[0] = 8'ha8;
    aa[2] = 8'h90;
    idx = 3'bzzz;
    r = aa[idx];
    $display("aa[3'bzzz] = %h", r);
    idx = 3'b0x1;
    aa[idx] = 8'h11;
    $display("after aa[3'b0x1] = 8'h11: num()=%0d aa[0]=%h aa[1] exists: %0d", aa.num(), aa[0],
             aa.exists(1));
  end
endmodule
