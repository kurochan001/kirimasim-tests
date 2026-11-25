# インターフェース内の specify と VPI

[English](vpi-interface-specify-interpretation.en.md)

<a id="interface-specify-path-ownership"></a>

## 規格上の二つの読み方

IEEE 1800-2023の37.6の図では、インターフェースからモジュールパスをたどる関係があります。37.39の本文はインターフェース内の `specify` を認め、パスの `vpiInstance` は所有するインターフェースを返し、互換用の `vpiModule` はNULLを返すと説明しています。

Annex A.1.6のインターフェース項目は、そこから参照する `module_common_item` を含む列挙で定義されます。Annex A.1.4では `specify_block` が `non_port_module_item` に含まれます。この構文に従うと、インターフェース内の `specify` は構文エラーになります。

二つのテストの期待値は37.39の本文に従っています。一方は同じインターフェースに二つのパスを置き、パスを持たないインターフェースと比較します。もう一方は二つのインターフェースインスタンスと一つのモジュールインスタンスで、パスの所有者を比較します。Ghost、Icarus Verilog 13.0、Verilator 5.052と5.054はいずれもインターフェース内の `specify` を拒否しました。該当する台帳3要件は未対応です。 [実行記録](../coverage/qualification/vpi-delay-ownership-20261125.json)
