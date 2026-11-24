/*
:name: test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds
:description: VPI rejects whole-value reads on array, object, virtual interface and nonvector aggregate variables while packed values remain readable
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 37.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds.expected
:vpi_c: @test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds.c
*/
interface variable_value_bus;
  int field = 37;
endinterface

module test_vpi_whole_value_is_unavailable_for_nonvalue_variable_kinds;
  typedef struct { int low; int high; } unpacked_record;
  typedef union { int a; int b; } unpacked_choice;
  typedef struct packed { bit [7:0] high; bit [7:0] low; } packed_record;
  typedef union packed { bit [15:0] word; packed_record halves; } packed_choice;

  class element;
    int field = 41;
  endclass

  int numbers[0:1] = '{11, 23};
  element object_handle = new;
  variable_value_bus bus();
  virtual variable_value_bus selected;
  unpacked_record mixed;
  unpacked_choice untagged;
  packed_record packed_fields = 16'h6a5c;
  packed_choice packed_word;

  initial begin
    selected = bus;
    mixed = '{low: 43, high: 53};
    untagged.a = 73;
    packed_word.word = 16'hb27d;
    #1 $vt_probe_nonvalue_variables;
    $display("direct=%0d %0d %0d %0d %0d", numbers[1], object_handle.field,
             selected.field, mixed.high, untagged.a);
  end
endmodule
