/*
:name: test_dpi_chandle_foreign_memory
:description: Memory that C allocates stays owned by C: SystemVerilog keeps only a chandle to it, passes it back to imported functions that use it, and has it freed by C (IEEE 1800-2023 Section 35.5.1.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.4 6.14 35.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_chandle_foreign_memory.c
:expected_stdout: @test_dpi_chandle_foreign_memory.expected
*/
// IEEE 1800-2023 §35.5.1.4: the memory of C and of SystemVerilog are
// separate, and each side frees what it allocated, but C may hand a pointer to
// a block to SystemVerilog, which passes it to an imported function that frees
// it. A chandle (6.14) holds the pointer: SystemVerilog only stores, copies
// and compares it and gives it back to c_read and c_release, which free the
// block in C. A chandle that was never set is null.

module test_dpi_chandle_foreign_memory;
  import "DPI-C" function chandle c_alloc(input int n);
  import "DPI-C" function int c_read(input chandle h, input int i);
  import "DPI-C" function void c_release(input chandle h);

  chandle h, copy, unset;

  initial begin
    h = c_alloc(4);
    copy = h;
    $display("allocated: %0d, copy equal: %0d, unset is null: %0d", h != null, copy == h,
             unset == null);
    $display("squares: %0d %0d %0d %0d", c_read(h, 0), c_read(copy, 1), c_read(h, 2),
             c_read(h, 3));
    c_release(h);
    h = null;
    copy = null;
    $display("released, now null: %0d", h == null);
  end
endmodule
