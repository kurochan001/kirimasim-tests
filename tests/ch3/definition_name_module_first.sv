// A source of test_illegal_definition_name_module_reused_in_other_file,
// compiled before it (:files:). It defines the module dn_file_name, whose
// name the test file uses again for an interface.
module dn_file_name;
  logic [3:0] state = 4'd5;
endmodule
