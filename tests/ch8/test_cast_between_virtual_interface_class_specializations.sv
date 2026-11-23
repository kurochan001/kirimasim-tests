/*
:name: test_cast_between_virtual_interface_class_specializations
:description: Class specializations using different virtual interface parameters remain distinct (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 25.9 6.24.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_between_virtual_interface_class_specializations.expected
:expected_exit: 0
*/
// A box parameterized by the eight-bit interface can be recovered through its
// base handle. Casting the same object to a box of the nine-bit interface
// must fail.

interface bus_if #(int W = 8);
  bit [W-1:0] data;
endinterface

module test_cast_between_virtual_interface_class_specializations;
  class base; endclass
  class box #(type T = int) extends base; endclass

  initial begin
    box#(virtual bus_if#(8)) src, restored;
    box#(virtual bus_if#(9)) other;
    base erased;
    bit same, different;
    src = new;
    erased = src;
    same = $cast(restored, erased);
    different = $cast(other, erased);
    $display("CHECK same=%0d different=%0d identity=%0d", same, different, restored == src);
    $finish;
  end
endmodule
