# program のインターフェースポートと VPI

[English](vpi-program-interface-port-interpretation.en.md)

<a id="program-interface-port-ownership"></a>

## 関係図とポート接続

IEEE 1800-2023 の37.9の図には、program からインターフェースとインターフェース配列を列挙する関係があり、逆方向には `vpiInstance` が示されています。インターフェースのインスタンス化は、24.3と附属書 A.1.7が定める program 本体の項目に含まれません。program のポートには、外側で宣言したインターフェースを接続できます。37.10では、`vpiInstance` がオブジェクトをインスタンス化した直近のインスタンスを返します。

- 読み方aでは、37.9の図の列挙対象にポート接続が含まれます。列挙から得られる program 側のオブジェクトの `vpiInstance` は program を返し、外側の実体から取得したオブジェクトの `vpiInstance` は宣言元を返します。
- 読み方bでは、図は program に属するインスタンスを対象とします。外側からポートを介して接続したオブジェクトの所有関係は接続によって変わらず、この列挙で別の program 側オブジェクトを作ることは指定されていません。

二つのテストは読み方aに従い、スカラー接続と配列接続を個別に検査します。Ghost は HDL 側の値を正しく読み出し、実体の所有元にモジュールを返し、program からの両一覧を空で返しました。Ghost と Slang 12.0.0 は、program 本体に直接インターフェースをインスタンス化した対照を拒否しました。ポート接続と図の関係が明確になるまで、37.9の四要件は未対応として扱います。 [観測値](../coverage/qualification/vpi-program-checkpoint-20261125-ghost-observations.json)
