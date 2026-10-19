/*
:name: test_memory_invalid_address_2state
:description: Out-of-range addresses of 2-state memories: writes do nothing and reads return 0 (IEEE 1800-2023 Section 11.5.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.2 7.4.5 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_memory_invalid_address_2state.expected
*/
// IEEE 1800-2023 §11.5.2, §7.4.5: an address outside the bounds of an unpacked
// array is invalid. Writing with it does nothing, and reading with it returns
// the default value of the element type (Table 7-1, 6.8), which is 0 for the
// 2-state types bit and int. This holds whether or not the number of elements
// is a power of 2, and for a negative address.
//
// Icarus Verilog 13.0 reads x from both memories. Verilator 5.052 drops the
// upper bits of the address, so it reads and writes another element.

module test_memory_invalid_address_2state;
  bit [7:0] bmem [0:3];
  int imem [0:2];
  int addr;

  initial begin
    foreach (bmem[i]) bmem[i] = 8'(i + 1);
    foreach (imem[i]) imem[i] = 10 * (i + 1);
    addr = 5;
    bmem[addr] = 8'hBB;
    imem[addr] = 99;
    addr = -1;
    imem[addr] = 77;
    $display("bmem = %0d %0d %0d %0d", bmem[0], bmem[1], bmem[2], bmem[3]);
    $display("imem = %0d %0d %0d", imem[0], imem[1], imem[2]);
    addr = 6;
    $display("read out of range: bmem=%0d imem=%0d", bmem[addr], imem[addr]);
    addr = -1;
    $display("read with -1:      imem=%0d", imem[addr]);
  end
endmodule
