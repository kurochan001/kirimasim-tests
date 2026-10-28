# 既存テストの要求照合：クラス・構築・メソッド（2026-10-23）

> この文書の件数・割合・保留状態は、各作業時点の記録です。
> 現在の値は[生成した集計概要](behavior-coverage-summary.md)、分母と解釈の承認経緯は
> [要求抽出の結果](requirement-extraction.md)を参照してください。

[現在のカバレッジ](behavior-coverage-summary.md) / [全テストの照合台帳](test-requirement-matching.md) / [前回の制御文・ループ](existing-test-matching-control-flow-20261023.md)

## 今回の進捗

提供されたIEEE 1800-2023の8章の関連本文と、各テストの刺激・期待出力全体を照合しました。
handle、constructor、static member、this、コピー、継承、virtual dispatch、pure prototype、castを対象としています。
ファイル名や宣言の存在だけを対応の根拠にはしていません。

- 一つ以上の要求との対応登録済み：813本から858本（全3,923本のうち45本追加）。
- 対応済み要求：698行から725行（27行追加）。新しい対応根拠は92件です。
- 実行確認済み要求：624行から651行（27行追加）。
- 暫定の要求カバレッジ（テスト設計）：**5.89%（725/12,319）**。
- 暫定実行確認率：**5.28%（651/12,319）**。
- 確定値：設計・実行とも未確定。分母承認・重複整理・解釈保留は残件です。
- 一つ以上の対応も未登録のテスト：3,065本。全件の検証内容に基づく対応付けは未完了です。

登録済み本数は一つ以上の観測を対応付けた本数で、各ファイルの全観測・全要求の精査完了数ではありません。
レビューはAIによるもので、独立した人の確認済みではありません。

今回、テスト入力・期待値・引用・ランナー・要求定義は変更していません。
全12,319行の定義、従来の対応・集合証拠・判断記録と、以前からの未コミット変更を保持しました。

## 採用した観測と集合証拠

[test_property_initializer_after_super_new.sv](../tests/ch8/test_property_initializer_after_super_new.sv) は、
base propertyの初期値1をconstructorで41へ変え、derived initializerがそれを読んで43を作り、
derived bodyがその43を記録して430へ変えます。期待値`b=41 seen_c=43 c=430`は、
base constructor、derived property initializer、derived bodyの順序を区別します。

[test_class_vs_struct_assignment.sv](../tests/ch8/test_class_vs_struct_assignment.sv) は、
`c2=c1`と`c3=new c1`を同じ刺激内で対照します。元を変更した後の値10/10/1と、
handle比較1/0が、aliasと別objectへのコピーを区別します。
[test_shallow_copy_array_properties.sv](../tests/ch8/test_shallow_copy_array_properties.sv) の
dynamic array・queue・固定配列の独立性も採用しました。

[test_typed_constructor_into_base_handle.sv](../tests/ch8/test_typed_constructor_into_base_handle.sv) は、
base型targetへ`child::new(7)`を代入し、child constructorの値17とvirtual readの値34を確認します。
[test_class_static_2.sv](../tests/ch8/test_class_static_2.sv) は、最初のnew前のcount0、生成後の1/3、
instanceごとのid1/2/3を確認し、staticの再初期化やinstance propertyの共有を区別します。

今回、次の3要求を新たに集合証拠にしました。集合証拠を持つ要求は累計24行です。
グループの全メンバーが同じ保存済み実行回で成功することを必要とします。

- 8.4 HANDLE-ASSIGNMENT：`test_class_null_comparison`の同型handle/null代入と、
  `test_class_basics`のalias経由の変更共有。Icarus／Verilatorの各全スイート結果で両方成功しています。
- 8.7 CONSTRUCTOR-ARGUMENTS：`test_class_new_args`の省略defaultと、
  `test_class_copy_2`のruntime property actual。Verilatorの同じ全スイート結果で両方成功しています。
- 8.20 VIRTUAL-LATEST-OVERRIDE：`test_method_virtual`の多段の最新override・継承したvirtual bodyと、
  `test_method_initial_extends`の同名nonvirtual methodの静的選択との対照。
  Verilatorの同じ全スイート結果で両方成功しています。Icarus側のknownは成功へ換算していません。

今回はシミュレータを再実行していません。入力未変更のため、保存済み全3,912本のIcarus 13.0／
Verilator 5.052の実行結果と現在の入力ハッシュを照合しました。
その後の追加・引用変更に対する部分実行結果も保持しています。
部分結果を全3,923本の一括再実行と扱ったり、異なる実行回の部分成功を集合証拠へ合成したりしていません。

## M29：自作copyメソッドと規格の浅いコピーの混同

[test_class_copy_corner.sv](../tests/ch8/test_class_copy_corner.sv)、
[test_class_copy_2.sv](../tests/ch8/test_class_copy_2.sv)、
[test_class_copy_3.sv](../tests/ch8/test_class_copy_3.sv) のcopy／shallow_copy／deep_copy／cloneは、
通常のconstructor呼び出しとfield代入によるユーザーメソッドです。
自作メソッド内でnested handleを共有しても、`new source`が規格どおり共有する証拠にはなりません。
constructor／宣言initializerの非実行や、動的classの複製も検証していません。

`test_class_copy_corner`のcloneは、戻り値こそ基底型ですが呼出元origは派生型です。
これだけで基底型handleを通したdispatchを確認したとはしません。
一方、`test_class_copy_2`には基底型からDog.copyを呼ぶ観測がありますが、引用に8.20がないため、
今回はconstructorやchained memberの観測だけを対応付けました。

[test_copy_obj.sv](../tests/ch8/test_copy_obj.sv) はaliasの変更共有と、後のnewによる独立性を確認します。
`new source`は使わず、handle代入に対応する8.4の引用もないため、その具体化を残件にしました。

## M30：実際の浅いコピーでも未観測の条件が残る

実際に`new source`を使う3本には、別objectへの値コピーの根拠があります。
ただしclass型propertyを持たず、nested objectのhandle共有、とくにproperty宣言でnewした場合の共有を確認しません。
配列propertyは値のコピーであり、nested class handleの共有と同一視できません。
このため、COPY-RESULT-ASSIGNMENTへ登録し、SHALLOW-MEMBER-COPYの複合行全体は保留しました。

constructor／宣言initializerの回数や副作用を観測しないので、それらを誤って実行してから
property値を上書きする実装も検出できません。base型handleでderived objectをコピーする刺激もなく、
COPY-NO-CONSTRUCTIONとCOPY-DYNAMIC-TYPEは未承認です。

## M31：static property・static method・automatic lifetimeの区別

[test_class_static_members.sv](../tests/ch8/test_class_static_members.sv) のstatic get_count/resetは未呼び出しです。
propertyの共有は確認できますが、methodの宣言だけを8.10の動作証拠にしていません。

static methodを実際に呼ぶテストでも、再帰や同時activationによる引数/local変数の分離は観測しません。
static class method修飾が引数/local変数をstatic lifetimeにしない要求は保留しました。

[test_class_static_corner.sv](../tests/ch8/test_class_static_corner.sv) のInitTestはinitializerの一度の表示を確認しますが、
InitTestのobject自体は一度もnewしません。newごとの再初期化を検出する根拠には、累積countと独立idの別テストを使いました。
[test_static_method_through_null_handle.sv](../tests/ch8/test_static_method_through_null_handle.sv) もstatic memberへのアクセスで、
nullからnonstatic member／virtual methodへアクセスする規格上禁止される操作の検証ではありません。

## M32：default引数・implicit constructor・初期化順序の区別

「Default constructor」と表示しても、明示した`function new`をdefault引数で呼ぶテストがあります。
implicit constructorの根拠には、newを宣言しないCalculatorを生成してmethodを実行する
[test_method_class.sv](../tests/ch8/test_method_class.sv) を採用しました。

[test_class_multilevel_inheritance.sv](../tests/ch8/test_class_multilevel_inheritance.sv) は、
derived bodyでbaseの値を上書きします。最終合計だけではbase constructorの実行や順序を確認できません。
先頭に正しく書いたsuper.newを成功させるだけの例も、後置呼び出しを許す誤実装との差が出ません。
順序には前述の41→43→430を使い、規格上正しい構文の成功と順序の観測を区別しました。

thisのproperty・戻り値・method選択には有効な観測がありますが、同じ要求行に含まれる
value parameter／localparamの選択は未観測です。formalとpropertyのshadowを区別する観測は
INNER-SCOPE-SHADOWへ登録し、より広い複合行は保留しました。

## M33：仮想呼び出しの対照と複合条件の不足

virtual宣言や派生型からの直接呼び出しだけでは、基底型handleを通したruntime lookupの証拠になりません。
基底型からの呼び出しを持つテストにも、nonvirtualの静的選択の対照や再宣言propertyの選択がない場合があります。
8.14の複合行全体へは登録せず、8.20の最新overrideには前述の集合証拠を設定しました。

`:initial`を付けたbase methodがnonvirtualのままである観測も、derived methodに`:initial`を付けて
nonvirtual base methodをoverrideする形式まで検証したことにはしていません。
通常のAnimalを基底とするテストも、abstract型変数の規則へは換算していません。

parameterized classのstatic分離には強い観測がありますが、非parameterized base経由の共有、
package／module各instanceでの型同一性、type/value-typeの条件をまとめた広い要求行は保留しました。

## M34：エラーテストの行番号だけの診断oracle

final override、initialによるvirtual override、extends対象の欠如、initial/extendsの併記、pure finalの5本は、
期待stderr正規表現がファイル名と行番号だけです。
新構文自体の未対応による構文エラーでも通り得るため、該当する意味制約の拒否を特定できません。
診断oracleの具体化と、構文対応環境での実行を残件にしました。

[test_final_class_and_method.sv](../tests/ch8/test_final_class_and_method.sv) の規格上正しい使用例も、
final methodのoverride禁止やfinal classの継承禁止の検証へは換算していません。

## M35：castのnull literal、失敗状態、task形式の不足

[test_dynamic_cast.sv](../tests/ch8/test_dynamic_cast.sv) のnull sourceは、Base型変数にnullを代入した値です。
literal nullを直接渡すケースとは異なります。
[test_class_cast_edge_cases.sv](../tests/ch8/test_class_cast_edge_cases.sv) とともに、
互換な実objectのchecked downcastとupcastは対応付けましたが、次は未観測です。

- incompatibleな静的型のsourceがnullの場合の失敗。
- destinationへsentinel handleを置き、失敗後も変更されないこと。
- task形式のcastと、失敗時の診断。

また、自作equalsとhandleの==による比較があっても、===/!==を実行しない
[test_class_compare.sv](../tests/ch8/test_class_compare.sv) は、それらの同等性の証拠にしていません。
生きているaliasを読み続けられるだけでも、到達不能objectのGCを観測したことにはなりません。

## 記録と検査

保留理由は[判断台帳](../coverage/test-matching-reviews.json)へ39本・53件を追記しました。
累計233本・267件で、部分観測・複合要求・引用具体化・oracle問題を分けています。
これらの判断はファイル全体のレビュー完了でも、カバレッジの加算対象でもありません。

既存の全要求定義・対応根拠・集合証拠・判断記録が保持されていることを、開始時のスナップショットと比較しました。
分母の承認状態は未変更です。

管理ツールの単体テスト74件、本文出典・coverage・matching・catalog・stats・depth・generatorの
整合性検査はすべて成功しました。metadataは新規問題0件、既知378件です。`git diff --check`も成功しました。
照合の追加によるシミュレーション再実行は行っていません。
