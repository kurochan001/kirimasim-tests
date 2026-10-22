/*
:name: test_interface_task_export
:description: a module connected through a modport that exports a task or function defines it as interface_port.name, and another module calls it through its importing modport; with extern forkjoin several modules can export the same task, and a call runs all of them as a fork-join (IEEE 1800-2023 Sections 25.7.3, 25.7.4)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_task_export.expected
*/
// IEEE 1800-2023 §25.7.3: a modport can export tasks and functions; the
// module connected through it defines them with the interface port name as a
// prefix, and a module connected through a modport that imports them calls
// them through its port (§25.7.2). §25.7.4: only an extern forkjoin task can
// be exported by more than one module; a call then runs the task of every
// exporting module as in fork-join and returns when all are done. Each memory
// answers reads of its own four addresses and counts itself. The function
// peek, declared extern in the interface, is exported by one module only.

`timescale 1ns/1ns

interface mem_bus;
  int data = 0;
  int targets = 0;
  extern forkjoin task count_targets();
  extern forkjoin task read_word(input int addr);
  extern function int peek(input int addr);
  modport target(ref data, targets, export count_targets, read_word);
  modport first(export peek);
  modport initiator(ref data, import task read_word(input int addr),
                    import function int peek(input int addr));
endinterface

module mem #(int base = 0) (mem_bus.target a);
  task a.count_targets();
    a.targets++;
  endtask

  task a.read_word(input int addr);
    if (addr >= base && addr < base + 4) #(2 + base) a.data = 100 * base + addr;
  endtask
endmodule

module peeker(mem_bus.first a);
  function int a.peek(input int addr);
    return -addr;
  endfunction
endmodule

module cpu(mem_bus.initiator b);
  initial begin
    #1 b.read_word(5);
    $display("%0d: read_word(5) gives %0d", $time, b.data);
    b.read_word(2);
    $display("%0d: read_word(2) gives %0d", $time, b.data);
    $display("peek(3) = %0d", b.peek(3));
  end
endmodule

module test_interface_task_export;
  mem_bus bus();
  mem #(0) m0(bus.target);
  mem #(4) m1(bus.target);
  peeker pk(bus.first);
  cpu c(bus.initiator);

  initial begin
    bus.count_targets();
    $display("targets = %0d", bus.targets);
  end
endmodule
