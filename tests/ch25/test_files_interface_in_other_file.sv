/*
:name: test_files_interface_in_other_file
:description: An interface declared in another source file can be instantiated and passed through a modport to a module of the test (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3 25.5 3.12.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: files_interface_in_other_file_if.sv
:expected_stdout: @test_files_interface_in_other_file.expected
*/
// IEEE 1800-2023 §25.3: an interface is declared once and instantiated where it
// is used; the one here is in a source file compiled before the test (:files:).
// Whether the two files form one compilation unit or two does not matter for a
// design element (§3.12.1). The module reads the interface through its modport
// (§25.5).
// Icarus Verilog 13.0 does not parse the modport in an interface port of a
// module.

module test_files_interface_in_other_file_reader(files_bus.reader b);
  initial #1 $display("data=%0d valid=%0d", b.data, b.valid);
endmodule

module test_files_interface_in_other_file;
  files_bus bus();
  test_files_interface_in_other_file_reader r(bus.reader);
  initial begin
    bus.data = 42;
    bus.valid = 1;
  end
endmodule
