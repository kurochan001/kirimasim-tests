/*
:name: test_memory_invalid_address
:description: Addresses of a 4-state memory that are out of range or have x bits: writes do nothing and reads return x (IEEE 1800-2023 Section 11.5.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.2 7.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_memory_invalid_address.expected
*/
// IEEE 1800-2023 §11.5.2: a memory address can be any integer expression,
// also another element of the same memory. An address that is out of range or
// has an x or z bit is invalid (7.4.5): writing with it does nothing, and
// reading with it returns the default value of the element type, x for a
// 4-state type. test_memory_invalid_address_2state checks a 2-state memory.

module test_memory_invalid_address;
  logic [7:0] mem [0:3];
  logic [2:0] addr;

  initial begin
    foreach (mem[i]) mem[i] = 8'(i + 1);
    addr = 3'b1x0;
    mem[addr] = 8'hAA;
    addr = 3'd5;
    mem[addr] = 8'hBB;
    $display("mem = %0d %0d %0d %0d", mem[0], mem[1], mem[2], mem[3]);
    addr = 3'b0x1;
    $display("read with x address: %b", mem[addr]);
    addr = 3'd6;
    $display("read out of range:   %b", mem[addr]);
    $display("mem[mem[0]] = %0d", mem[mem[0]]);
  end
endmodule
