// The interface of tests/ch25/test_files_interface_in_other_file.sv, compiled
// before it through :files:.
interface files_bus;
  int data;
  bit valid;
  modport reader(input data, valid);
endinterface
