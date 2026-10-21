// Modules for tests/ch23/test_top_module_excludes_file_module.sv: the counter
// it instantiates, and a stray module that nothing instantiates.
module files_top_counter #(parameter int START = 0);
  int value = START;
endmodule

module files_top_stray;
  initial $display("the stray module runs");
endmodule
