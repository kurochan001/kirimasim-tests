// A source of test_files_module_in_other_file, compiled before it (:files:).
module files_module_in_other_file_adder #(parameter int W = 8)
  (input logic [W-1:0] a, b, output logic [W:0] sum);
  assign sum = a + b;
endmodule
