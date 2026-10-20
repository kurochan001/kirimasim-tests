/*
:name: test_memory_words
:description: A one-dimensional array of logic, bit or reg elements is a memory: each element is a word written and read by its address, and a part of a word can be selected after the address (IEEE 1800-2023 Section 7.4.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.3 7.4.1 7.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_memory_words.expected
*/
// IEEE 1800-2023 §7.4.3: a one-dimensional array whose elements are reg,
// logic or bit is a memory, and each element, a word, is addressed by its
// index. rom is filled once and read by address; regs is a register file of
// reg words written by address; a bit-select or part-select after the address
// picks bits of one word (7.4.6). Words never written keep their initial
// value: x for logic and reg, 0 for bit.

module test_memory_words;
  logic [7:0] ram [0:15];
  bit [3:0] rom [0:3];
  reg [15:0] regs [1:4];
  int addr;

  initial begin
    foreach (rom[i]) rom[i] = 4'(i * 3);
    ram[5] = 8'ha5;
    addr = 5;
    regs[2] = 16'hbeef;
    $display("ram[5]=%h ram[6]=%h rom[3]=%0d rom[0]=%0d", ram[addr], ram[addr + 1], rom[3],
             rom[0]);
    $display("regs[2]=%h regs[1]=%h high byte=%h bit 0=%b", regs[2], regs[1],
             regs[2][15:8], regs[2][0]);
  end
endmodule
