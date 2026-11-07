<a id="generator-catalog"></a>

# 生成器カタログ

[English](generators.md) / [日本語](generators.ja.md)

現在の107生成器から5,200件のテストを生成しています。
通常の全件数と、有限クロスモデルの短時間選択の件数は別です。各行は通常の生成件数です。

この資料は`tools/generator_catalog.py`で生成します。生成器の因子・合法条件・観測点と期待値は、各ソースと[クロス設計](interaction-verification.md)を確認してください。

| 生成器 | 章 | テスト数 | 確認する動作 |
| --- | --- | ---: | --- |
| [`combination_aggregates`](../generators/combination_aggregates.py) | 6, 11, 13 | 18 | 境界条件18件。アンパック構造体の参照渡しと寿命、配列のinputコピー、ネストしたパック選択、文字列やネストした代入先へのストリーミングを確認 |
| [`combination_events`](../generators/combination_events.py) | 6, 9, 15 | 9 | 境界条件9件。自動変数のeventの寿命、戻り値・条件式で選択したevent、計算したイベント制御、`iff`、遅延トリガ、名前付きforkの終了処理を確認 |
| [`combination_io`](../generators/combination_io.py) | 9, 10, 21 | 13 | 境界条件13件。`$fread`の格納先とバイト順、キュー・動的配列の暗黙感度、SV内で読み戻したVCDの内容を確認 |
| [`combination_monitors`](../generators/combination_monitors.py) | 21 | 18 | 9種類の登録場所と2種類のコンテナ・記述子を組み合わせ、ファイルを読み戻して、Postponedの最終値、非選択要素、選択・置換、monitoroff、閉鎖後の出力抑止を確認する。 |
| [`combination_nba`](../generators/combination_nba.py) | 10, 13 | 16 | 境界条件16件。`ref static`経由の遅延・イベント制御付きNBA、値と添字の確定、文字列の文字要素、配列スライスのコピーアウトを確認 |
| [`interaction_array`](../generators/interaction_array.py) | 7 | 36 | 2組の入力を配列全体／スライスへコピーし、宣言順の対応、非選択要素の保持、コピー元変更後の独立性と、読み出した要素の符号拡張を確認する。 |
| [`interaction_assertion`](../generators/interaction_assertion.py) | 16 | 36 | 更新前後の既知値とX/Zで、assertionのpass/fail回数、サンプル値と1ビットの式の値、Reactiveのライブ値と最終値を観測する。型、式、エッジ、blocking/NBA、更新時点、module/interfaceを組み合わせ、サンプリング時点とaction実行時点を区別する。 |
| [`interaction_assocquery`](../generators/interaction_assocquery.py) | 20 | 18 | 連想配列の挿入・上書き・削除・再利用で、添字型の範囲と割当て済みの範囲、問い合わせのinteger変換とfirst/lastの幅・符号、要素数と全キー/値を照合する。 |
| [`interaction_binding`](../generators/interaction_binding.py) | 13 | 36 | 呼出し後に添字を同値・次要素・-1へ変更し、実引数と仮引数の複数時刻の値を観測して、元の要素への結合、inputの値コピー、refの双方向の可視性、const refのライブな読取り、復帰時の書戻しや隣接要素の破壊がないことを確認する。 |
| [`interaction_case`](../generators/interaction_case.py) | 12 | 36 | セレクタと項目値を表示し、重複項目とフォールバック項目の2回の分岐結果から、幅・符号の統一、X/Zの扱い、最初に一致した項目の優先を確認する。 |
| [`interaction_case_inside`](../generators/interaction_case_inside.py) | 12 | 34 | 値・範囲・固定配列・2値のリストを先頭項目にしたcase insideで、各項目とdefaultを狙う4組のケース式、格納後の項目値、選ばれた分岐、ケース式と数える項目の評価回数を観測し、Xの比較を不一致として後続へ進むこと、端点の拡張、unique0の評価を確認する。 |
| [`interaction_cast`](../generators/interaction_cast.py) | 6 | 32 | 元の値・キャスト直後の値・後続演算の結果を分けて表示し、キャストの幅と符号、演算前のX/Z変換、外側の代入コンテキストと最終変換の順序を確認する。 |
| [`interaction_cgsample`](../generators/interaction_cgsample.py) | 19 | 33 | 配列・キューの変更前後でサイズ・先頭/末尾値をsampleし、直接参照と引数、空のガード、必要ヒット数と対象/対照それぞれのbin履歴を照合する。 |
| [`interaction_checksample`](../generators/interaction_checksample.py) | 17 | 27 | checkerとmodule参照モデルで、判定・サンプル値・Reactiveの値・実行時刻を照合する。接続形式と配置を変え、2実体の独立性と出力引数の伝播も観測する。 |
| [`interaction_class_array`](../generators/interaction_class_array.py) | 8 | 18 | クラスの浅いコピーとハンドル代入を対照に、配列領域の独立性と要素ハンドルの参照先の共有を照合する。元/コピーからの要素置換・拡大/縮小、保存ハンドルの存続、コンストラクタ回数と別guardの保持を確認する。 |
| [`interaction_class_import`](../generators/interaction_class_import.py) | 26 | 34 | メソッド内のimportとクラスプロパティ、外側moduleの同名宣言の名前解決を照合する。幅・符号・状態型、function/task、別名とハンドル再束縛を交差し、package共有値・個別オブジェクト・別メソッドの更新と保持を分けて観測する。 |
| [`interaction_class_method`](../generators/interaction_class_method.py) | 8 | 36 | 2個の派生インスタンスをA/B/A順に呼び、virtual/非virtualの実行本体と所有者、再帰の入口・出口の仮引数とプロパティ、戻り値・カウンタ・ガードを観測する。inputのフレーム別コピーとref/const refの同一実体への参照、2状態変換を確認する。 |
| [`interaction_class_select`](../generators/interaction_class_select.py) | 8 | 36 | クラスの直呼びと基底ハンドル経由の呼出しで条件選択・更新先・早期returnを照合する。if/caseと条件演算子のX/Z、型付き結果の符号拡張、別名と再束縛後のオブジェクトの独立性を観測する。 |
| [`interaction_clockassert`](../generators/interaction_clockassert.py) | 16 | 18 | 既定/明示の#1step clocking入力を、そのイベントと後続の別クロックのアサーションで観測する。更新の前後とblocking/NBA、独立したエッジ極性を組み合わせ、sampled値・Reactiveの生信号・判定回数を分けて照合し、別クロックでの誤った再サンプリングを検出する。 |
| [`interaction_clockevent`](../generators/interaction_clockevent.py) | 14 | 24 | clocking入力から名前付きイベントで待機者へ通知し、受信直後と生信号変更後の採取値・生値を照合する。入力skew・エッジ・更新方式・通知方式・待機者数・幅を交差し、別イベントによる誤起床と反復時の再待機も観測する。 |
| [`interaction_clockiff`](../generators/interaction_clockiff.py) | 14 | 12 | iffで選別したclocking eventとrawエッジを別計数し、通過時の採取と不通過時のサンプル保持を照合する。ガードだけの前後の変更、33ビットの上位1、入力skew・更新方式を交差し、cbと観測器の値を比較する。 |
| [`interaction_clocking`](../generators/interaction_clocking.py) | 14 | 36 | 3組の背景値でクロック前の値と更新後の値、cbでのサンプルとライブ値、起床回数を観測し、#1step/#0、blocking/NBA、状態型、クロック方向とlocal/interface/virtual modportの参照経路の相互作用を確認する。X/Z行にも既知値の対照を保持する。 |
| [`interaction_compare`](../generators/interaction_compare.py) | 11 | 100 | 4組の入力で幅・符号の統一、未知値と既知の不一致、右辺だけのワイルドカードを確認し、1ビットの比較結果を広いlogic/bitへ直接代入して変換順序を観測する。 |
| [`interaction_compound`](../generators/interaction_compound.py) | 11 | 40 | 複合シフト代入の前後にスカラ・配列全要素・親ベクタ・拡張値と添字関数の回数を観測し、左辺の1回評価、部分選択の符号、シフト量の独立した幅と型変換を確認する。 |
| [`interaction_concat`](../generators/interaction_concat.py) | 11 | 72 | 2組の既知入力とX/Zの入力で、連結全体への拡張と分割、各項の状態変換、即時更新とNBAの値確定、各項と連結を読み出す際の符号の違いを確認する。 |
| [`interaction_cond`](../generators/interaction_cond.py) | 11 | 32 | 両分岐の入力と条件演算の結果を表示し、分岐選択・X/Zのビットごとの結合・符号拡張・代入先の幅と2状態変換を一連の式で確認する。 |
| [`interaction_config`](../generators/interaction_config.py) | 33 | 41 | configの設定・Wだけのリセット・全パラメータのリセットを、既定値・インスタンス指定・defparamと比較する。通常階層の親パラメータとconfig localparamの隠蔽、生成した幅・個数・if/case分岐、対象外の兄弟を観測する。 |
| [`interaction_constraint`](../generators/interaction_constraint.py) | 18 | 13 | 基底/派生ハンドルから3階層の継承制約を解き、同名の置換・別名の追加とpure/externの完了を照合する。一意解と矛盾を交互に与え、初回失敗時の初期値・成功後の値の保持と、別オブジェクトの独立した成功を確認する。 |
| [`interaction_default`](../generators/interaction_default.py) | 13 | 36 | A/B/Aの階層呼出しで既定値の元を毎回変え、両仮引数・戻り値と宣言側/呼出し元の関数評価回数を観測する。省略・空欄・名前付き・明示0での評価抑止、呼出し時の宣言スコープへの束縛、型変換とmodule/interfaceの各インスタンスの独立性を確認する。 |
| [`interaction_deferarg`](../generators/interaction_deferarg.py) | 13 | 29 | 遅延報告の値渡しと静的な参照渡しを、登録時の取得値・報告時の生値・幅変換と照合する。関数とタスク、報告領域、更新方式、幅と符号を交差し、引数評価の副作用と実行時刻も観測する。 |
| [`interaction_deferdis`](../generators/interaction_deferdis.py) | 16 | 31 | disable対象のスコープと未成熟の遅延報告を、兄弟・別プロセスの対照、引数取得と副作用、報告時の生値・通常の制御移動・報告済み履歴の保持と照合する。 |
| [`interaction_delay`](../generators/interaction_delay.py) | 10 | 63 | 幅1のスカラと幅2以上のベクタで1/2/3個の遅延を使い、短パルスの除去と予約の取消しを観測する。bit/logic格納と反転後の値、X/Zの遅延選択、全体値の更新時刻・回数・最終変化時刻を毎tick照合する。 |
| [`interaction_dist`](../generators/interaction_dist.py) | 18 | 31 | 演算子の優先順位と括弧、幅・符号、distの重みと重複項目を照合する。候補値から解を一意にし、全重みゼロによる失敗時の値保持を、毎回成功する別実体と比較する。 |
| [`interaction_divide`](../generators/interaction_divide.py) | 11 | 72 | 両オペランドと演算結果を観測し、演算前の幅・符号の統一、商の0方向への丸め、剰余の符号、ゼロ除算とX/Zの伝播、最終的な2状態変換を確認する。 |
| [`interaction_dpi_array`](../generators/interaction_dpi_array.py) | 35 | 30 | 固定/動的配列/キューをopen arrayとしてDPIへ渡し、各呼出しの範囲・全要素・復帰後の書戻しを照合する。入力方向・数値順の走査方向・符号パターン・繰返し前の拡大/縮小を交差し、別のguard配列の保持も確認する。 |
| [`interaction_dpi_nba`](../generators/interaction_dpi_nba.py) | 35 | 18 | DPIのinput/output/inoutとNBA予約の前後、同じ/別の配列要素を組み合わせる。幅・符号・bit/logicからintへの変換、復帰直後の書戻し、予約後の添字・値の変更、Postponedと次時刻の全要素を照合し、NBAの値と代入先の確定を確認する。 |
| [`interaction_dpiquery`](../generators/interaction_dpiquery.py) | 20 | 19 | 同じ実引数のSV/DPI-C問い合わせを、次元番号の対応・packed範囲の正規化・各次元の範囲とincrement・呼出しごとの形状更新で照合する。 |
| [`interaction_edge`](../generators/interaction_edge.py) | 9 | 64 | 両背景で初期イベントを除外し、更新直後の値と次時刻の3カウンタを観測して、X/Z遷移、式の変化、ベクタのLSB規則、状態変換、NBAの更新時点を確認する。 |
| [`interaction_event_rebind`](../generators/interaction_event_rebind.py) | 15 | 27 | 静的イベントをタスク呼出し前・待機登録前・登録後に再結合し、inputのコピーとref/直接参照、登録済み待機の保持、複数待機者、後着待機者、別名の独立性とActive/NBAの観測値を照合する。 |
| [`interaction_event_task`](../generators/interaction_event_task.py) | 15 | 13 | module/interfaceの別インスタンスまたはpackageの2イベントをinput/refで渡し、1/2/3待機者の時刻・回数・値を観測する。待機前のトリガの不保持、通常/NBA起床の値の可視性、トリガ経路、逆順での再待機、noiseと完了後の余計な起動を区別する。 |
| [`interaction_eventflow`](../generators/interaction_eventflow.py) | 15 | 36 | 名前付きイベントを読むforループでbreak/continueと待機開始順を交差し、受信と保持の履歴を照合する。同じタイムスロットのtriggeredとエッジ待機、NBA発火、別イベントの独立性と取消し後の再待機を観測する。 |
| [`interaction_eventlife`](../generators/interaction_eventlife.py) | 15 | 18 | 自動タスク復帰後の構造体内イベントの同一性・別名解放・遅延した待機登録と、別呼出しの独立性・全体コピー後のpayload・起床時刻を照合する。 |
| [`interaction_expr`](../generators/interaction_expr.py) | 11 | 51 | 4組の入力で加減乗算の結果を確認する。演算前の符号・ゼロ拡張、代入先からの幅の伝播、キャリー、最終的な切り捨てを組み合わせる。 |
| [`interaction_force`](../generators/interaction_force.py) | 10 | 72 | 変数・連続代入・assign・網・部分選択・wor・連結をforceし、その間と後にドライバと右辺の信号を変える。各段階の値を$display・$strobe・$monitor・@・ビット問い合わせ関数で読む。 |
| [`interaction_gatearray`](../generators/interaction_gatearray.py) | 28 | 51 | 4個のゲートの配列へ昇順・降順のベクタ、部分選択、連結、スカラをつなぎ、ビットの対応を調べる。既知値・X/Z・既知値の変化で、各出力の真理値表と立上り・立下り・ターンオフの遅延を半時刻で読む。 |
| [`interaction_gendisable`](../generators/interaction_gendisable.py) | 16 | 18 | generate内でのdefault disable iffの継承・上書き・名前解決・宣言位置と、明示条件・ゼロによる取消しを照合する。二つの実体を独立に無効化し、開始前・クロック間・終了クロックのNBAで、無効化と成功・失敗の回数を対照と比較する。 |
| [`interaction_genenum`](../generators/interaction_genenum.py) | 6 | 36 | generateの反復と分岐が列挙型の幅と値表を決め、符号・宣言順・巡回数とnext/prevの観測へ反映される。二初期状態と別要素の操作後・アイドル時の読出しで、値と保持したコピーの独立性も照合する。 |
| [`interaction_generate`](../generators/interaction_generate.py) | 27 | 36 | 2インスタンスのgenerate要素を階層名で読み、選択分岐・局所宣言・genvar定数・型幅・package定数と連続代入の値を観測する。importと明示修飾、入れ子、型と定数の隠蔽、X/Zを含む入力変更への追従と各スコープの独立性を確認する。 |
| [`interaction_genexpr`](../generators/interaction_genexpr.py) | 27 | 36 | 定数式のオペランド符号・代入文脈の幅・結果の宣言符号を分離し、生成分岐・個数・幅を照合する。$bitsによる形状、各生成要素の全幅データ、別実体の保持、X/Zと既知値への回復を観測する。 |
| [`interaction_genloop`](../generators/interaction_genloop.py) | 27 | 36 | 生成プロセスごとの配列走査とbreak/continueを、訪問数・保持数・重み・全幅の結果で照合する。一スコープの入力変更、別guardの更新、立上りでの再起動、立下りと待機中の状態保持を観測する。 |
| [`interaction_gensub`](../generators/interaction_gensub.py) | 27 | 36 | 生成スコープごとに異なる型・範囲の配列とサブルーチンを宣言し、既定引数の結合先と再評価を照合する。function/taskの入出力変換、呼出し順序、外部更新後の再呼出し、隣接要素と別スコープの状態保持を観測する。 |
| [`interaction_ifexpr`](../generators/interaction_ifexpr.py) | 25 | 49 | 符号付き8・符号なし8・符号付き4ビットのメンバを、ポート・modport・総称ポート・配列の要素・階層名から読む。除算・算術シフト・比較・単項マイナス・乗算と、文の制御・importしたtaskによる共有の更新を確かめる。 |
| [`interaction_iff`](../generators/interaction_iff.py) | 9 | 27 | 独立した左右のイベント数と条件付きORの起床数、条件だけを変えた後の保持を観測し、iffの項ごとの結合、orとカンマの同義性、名前付きイベントの再発火、X/Zを含む条件の真偽、ブロッキング/NBAの更新時点を確認する。 |
| [`interaction_ifgenerate`](../generators/interaction_ifgenerate.py) | 27 | 36 | generate要素ごとに幅の違うinterfaceを2個置き、if/caseで選択した側をwhole/modportのwriter/readerへ接続する。bit/logicへの格納前の反転、非選択側の対照、実際の幅・識別タグ・接続先と全要素の独立性を観測する。 |
| [`interaction_ifimport`](../generators/interaction_ifimport.py) | 25 | 36 | interfaceヘッダのimportでパラメータ既定値・型・package関数を結合し、targetだけの幅/タグ変更をguardと比較する。同名の呼出し側宣言を対照に、bit/logicの仮引数変換がpackage関数の演算前に行われる順序と実際の幅・中間値を照合する。 |
| [`interaction_ifquery`](../generators/interaction_ifquery.py) | 25 | 36 | interface内の配列問い合わせが走査の開始位置・回数・方向と型付き結果を決める。全要素・両次元の境界・単一要素・別実体の保持・入力変更後の再呼出しを照合する。 |
| [`interaction_import`](../generators/interaction_import.py) | 23 | 39 | packageのwildcard/明示import、局所宣言、.*・.name・明示接続で入力の接続先と既定値を区別する。既定値0/全1の2子と独立した対照スコープを観測し、ライブ値の追従・隠蔽・型変換を確認する。 |
| [`interaction_index`](../generators/interaction_index.py) | 11 | 44 | 可変インデックスのビット列と書き込み前後の全ビットを観測し、添字の符号、範囲の始点と向き、無効な読み取りの既定値、無効な書き込み時の保持を確認する。 |
| [`interaction_inside`](../generators/interaction_inside.py) | 11 | 46 | 個別列挙・固定配列・動的配列・キューの要素とサイズ、異なる幅・符号の入力、生の判定値・拡張・bit変換・逆順リストを観測し、片側ワイルドカードとORを確認する。 |
| [`interaction_literal`](../generators/interaction_literal.py) | 5 | 66 | 基数・符号・桁数・先頭桁を変えたリテラルを、直接・localparam・マクロの字句・continuous assignで運ぶ。左への詰めと切り捨て、式の文脈による拡張、代入先の幅とbitへの変換を全ビットで観測する。 |
| [`interaction_litfmt`](../generators/interaction_litfmt.py) | 21 | 91 | x・zの詰め、?、下線、unbased unsized、符号、否定、エスケープを含むリテラルを各書式で表示する。自動の桁数・幅0・幅指定と、localparam・マクロ・連結、書式のない表示タスクの扱いを確かめる。 |
| [`interaction_logic`](../generators/interaction_logic.py) | 11 | 70 | 各行で全6リダクションと論理否定の入力・実際の式・結果を観測し、支配値とX/Z、演算前後の状態変換、1ビットunsigned結果の拡張、入力の自己決定幅を確認する。 |
| [`interaction_loop_nba`](../generators/interaction_loop_nba.py) | 10 | 36 | for/while/repeat内の複数代入で、途中結果を使うblockingと旧値からNBAを予約する動作を区別する。A/B/A呼出しの各反復の値・添字、ActiveとNBA後の全要素・カウンタ・ガードを観測し、書込み順序、状態変換、module/interfaceの独立した格納先を確認する。 |
| [`interaction_loopsched`](../generators/interaction_loopsched.py) | 12 | 55 | repeat・while・for・do・foreverの制御変数を、別プロセスがNBA・#0の後・後の時刻に変える。待ちのない本体・#0・#2で、回数と$display・$strobe・$monitorが示す値を確かめる。 |
| [`interaction_macro`](../generators/interaction_macro.py) | 22 | 114 | マクロの定義の形・本体の括弧・実引数を、11の文脈とコンパイル単位の中の定義の置き方で交差する。文字として展開されるので、外側の演算子や優先順位の低い実引数の結合を値で確かめる。 |
| [`interaction_mailbox`](../generators/interaction_mailbox.py) | 15 | 36 | classハンドルをtyped/typelessのmailboxへ渡し、FIFO・get/peek・容量制限・nullメッセージと取得前後の双方向のメンバ更新を確認する。別mailboxの保持と後の更新、空の非ブロッキング戻り値も観測する。 |
| [`interaction_memfile`](../generators/interaction_memfile.py) | 21 | 36 | bit/logicと列挙型のメモリファイルを出力し、元配列の変更後に別の添字範囲へ読み込む。独立に用意した入力も読み込み、要素の値・範囲外の保持・宣言方向と読込み順・上書きを照合する。 |
| [`interaction_method`](../generators/interaction_method.py) | 7 | 72 | 固定長配列・動的配列・キューの集計を2組の背景値で観測し、with式による要素の型変換、戻り値の幅、オーバーフロー、X/Z伝播と呼出し後の拡張を確認する。 |
| [`interaction_nba`](../generators/interaction_nba.py) | 10 | 36 | 代入直後・刺激変更後・時刻1・最終結果の出力で、値と代入先の確定、隣接要素の保持、Active領域とNBA領域の順序、automaticタスクからの復帰後の更新を確認する。 |
| [`interaction_nettype`](../generators/interaction_nettype.py) | 22 | 40 | ANSI/非ANSIのポート宣言でnet型を省略し、default_nettypeによるvectorとscalarの解決値・幅を親子で照合する。vectorだけの明示wireによる上書きと、指示解除後の別moduleを同じ刺激で比較し、既定型の適用範囲を確認する。 |
| [`interaction_pkgnba`](../generators/interaction_pkgnba.py) | 26 | 36 | 二つのモジュールから同じpackage変数へ順にNBAを予約し、参照方法・配列添字・遅延・状態型を交差する。値と代入先の取得、予約順序、別名での読出し、隣接要素と別packageの保持をActiveとNBA後で照合する。 |
| [`interaction_pkgquery`](../generators/interaction_pkgquery.py) | 26 | 36 | 関数内のimportと修飾参照が配列問い合わせの対象を決め、開始位置・回数・方向と全幅集計を変える。非選択packageと同名ローカル配列の更新後も、対象配列の型・全要素・履歴を保持することを照合する。 |
| [`interaction_pkgwatch`](../generators/interaction_pkgwatch.py) | 26 | 36 | 同じpackage変数への複数のイベント待機とwait、関数内の外部参照を読むalways_combを照合する。全体と最下位ビットの感度、条件のX、再書込み・隣接要素・別packageの通知と起床履歴を観測する。 |
| [`interaction_port`](../generators/interaction_port.py) | 23 | 36 | 親と子の間で幅が変わる接続を使い、元の値・4状態の接続線・サンプル変数を観測して、接続方向、駆動元の符号、宣言と接続形式、最後の2状態変換を確認する。 |
| [`interaction_process`](../generators/interaction_process.py) | 9 | 36 | 宣言時初期値による時刻0の起動、data/maskと関数内部の読取りによる再実行、0/X/Zでのcombの既定値とlatchの保持を観測する。1変数ずつ変更して両インスタンスの出力・評価回数を確認し、無関係なnoiseと自己更新による余分な起動も区別する。 |
| [`interaction_progassert`](../generators/interaction_progassert.py) | 24 | 27 | programとmodule参照モデルの各クロック試行を、単周期判定・同サイクル/次サイクル含意で照合する。空虚な成功と未完了の試行を区別し、判定数と完了時のサンプル値総和を出力引数から観測する。 |
| [`interaction_progframe`](../generators/interaction_progframe.py) | 24 | 36 | 重なるautomatic taskの局所値とoutput/inoutのコピーを、programの終了範囲と復帰方法を変えて照合する。途中終了時のコピー抑止、生存する別program、符号拡張、配列の隣接要素と再呼出しの履歴を観測する。 |
| [`interaction_program`](../generators/interaction_program.py) | 24 | 18 | programの自然終了と直接/タスク内の$exit、複数initial、子/孫プロセスの待機を組み合わせる。終了前の進捗と終了後の書込み取消し、同じ待機条件を持つ別programの起床、最後のprogramによる暗黙終了を観測する。 |
| [`interaction_query`](../generators/interaction_query.py) | 20 | 60 | 引数の実ビット列・幅と各関数の結果を表示し、式の形、状態変換、X/Zの位置、制御ビットの重複除去、one-hot判定と未知値の有無を確認する。 |
| [`interaction_queue`](../generators/interaction_queue.py) | 7 | 48 | 2組の入力でサイズと全要素、取り出した値、操作前のコピーを観測し、追加位置と容量による破棄、空の既定値、型変換、値コピーの独立性を確認する。 |
| [`interaction_queue_ref`](../generators/interaction_queue_ref.py) | 7 | 60 | 3組の入力で保持中の参照値・変更後の全要素・2回の書込み後・値コピーを観測し、要素の移動後の同一性、削除・全体代入後の古い参照の存続と書込みの分離、容量超過での末尾要素の破棄、bit/logicの引数変換を確認する。 |
| [`interaction_randreduce`](../generators/interaction_randreduce.py) | 18 | 13 | 固定配列と動的配列の一意な解と矛盾を切り替え、要素型とwith式の型でのリダクション、演算前の拡張、失敗時の全要素とサイズの保持、独立した対照オブジェクトを照合する。 |
| [`interaction_range`](../generators/interaction_range.py) | 11 | 46 | 閉区間・逆順・$端点・絶対/相対許容差の範囲で、端点の格納値、各端点の前後の入力、生の判定値・拡張・bit変換と関係演算子での同じ判定を観測し、範囲の比較と集合値のワイルドカードの違い、許容差の端点の入れ替えと切り捨てを確認する。 |
| [`interaction_reactive`](../generators/interaction_reactive.py) | 24 | 36 | moduleのNBA連鎖の完了前後を、早いmodule内の対照とReactiveで動くprogramで観測する。連続代入・blocking・Re-NBAの出力と採取値、型変換、全段の値・NBA予約回数・採取した文脈を照合する。 |
| [`interaction_resize`](../generators/interaction_resize.py) | 7 | 38 | 再確保前後のサイズと全要素を観測し、別配列コピー・自己リサイズ・初期化式なしの再生成、切り詰め、追加領域の型別既定値、コピー後の独立性を確認する。 |
| [`interaction_return`](../generators/interaction_return.py) | 13 | 36 | for/while/repeat内で最初の非0ビットからreturnし、戻り値・走査回数と添字の総和・末尾到達・return後の副作用を観測する。A/B/A呼出しでインスタンス別状態とpackageの共有状態、呼出し元の同名変数の保持、X/Zの2状態変換も確認する。 |
| [`interaction_scansel`](../generators/interaction_scansel.py) | 21 | 36 | 文字列の読取りが途中で止まる位置と成功した書込みだけを、戻り値・全語・部分選択外の保持で照合する。$bitsを使う実行時書式、文字数としてのフィールド幅、既知ASCIIのX/Z数字と格納時の変換を観測する。 |
| [`interaction_sdfpath`](../generators/interaction_sdfpath.py) | 32 | 18 | SDFの条件・注釈範囲・置換/加算と、立上り/立下りの遅延を照合する。兄弟インスタンスと別出力を対照とし、値・変化回数・最終変化時刻を観測する。 |
| [`interaction_select`](../generators/interaction_select.py) | 11 | 36 | 部分選択への書き込み前後にベクタ全体と選択範囲を表示し、添字方向・選択方向・X/Z変換に加え、選択していないビットの保持も確認する。 |
| [`interaction_sense`](../generators/interaction_sense.py) | 4 | 61 | always_comb・always_latch・@*・連続代入で読む式の形を変え、読む部分と読まない部分へ書き込む。再評価の回数と出力の値で、最長静的接頭辞と関数の中の読出しの扱いを確かめる。 |
| [`interaction_shift`](../generators/interaction_shift.py) | 11 | 56 | シフト前の値・シフト量・結果を表示し、代入先から伝わる幅、符号付きの埋め込み、X/Zの移動、未知のシフト量、最後の2状態変換を確認する。 |
| [`interaction_shortcircuit`](../generators/interaction_shortcircuit.py) | 11 | 92 | 4演算ごとに左右の関数の呼出し回数・観測値・独立した副作用を表示し、短絡による右辺の評価抑止、未知値の真偽変換、結果と最終格納先の状態変換を確認する。 |
| [`interaction_stream`](../generators/interaction_stream.py) | 11 | 36 | 入力ストリームと結果を比較し、ブロック順、端数ブロック、複数項目の連結、packとunpackの逆変換、2状態の格納先への変換を確認する。 |
| [`interaction_strengthfmt`](../generators/interaction_strengthfmt.py) | 21 | 31 | 2ドライバの競合・解放とtri0/tri1のpull既定値を、3種類のformat APIで値と強度を分けて照合する。強度差・更新順・極性を交差し、全11観測の上書きと独立したsupply対照を確認する。 |
| [`interaction_struct`](../generators/interaction_struct.py) | 7 | 36 | 構造体の全ビット・payload・tagと、メンバ／全体の拡張結果を観測し、配置、更新領域、NBAの値の確定、各式の符号属性を確認する。 |
| [`interaction_task`](../generators/interaction_task.py) | 13 | 36 | タスク内部・復帰直前・復帰後から実引数を観測し、コピー渡しと参照渡しの更新時点の違い、値と隣接要素の保持を確認する。 |
| [`interaction_timescope`](../generators/interaction_timescope.py) | 3 | 48 | taskの遅延の時間スコープを宣言・`timescale・$unit・入れ子で決め、効かないはずの指定も置く。遅延の換算と精度への丸めを、$time・$stime・$realtime・%tの読出しで呼出し元のスコープと比べる。 |
| [`interaction_udp`](../generators/interaction_udp.py) | 29 | 25 | 組合せUDPの配列へベクタをビット分配し、スカラーを共通接続する。単独出力・競合する別ドライバ付きの出力・名前なしの単一UDPを比較し、強度・全4状態の入力対・位置識別を照合する。 |
| [`interaction_udpstate`](../generators/interaction_udpstate.py) | 29 | 36 | generateで初期値の異なる逐次UDPをビットごとに選択し、共通/交互のクロックで個別の状態を採取・保持する。bit/logicへのX/Z格納、未知入力前の全1準備、既知値への回復、別クロックの対照の保持と後の採取を照合する。 |
| [`interaction_vif_class`](../generators/interaction_vif_class.py) | 25 | 13 | クラスのvirtual interfaceの結合を浅いコピー/ハンドル代入で比較し、再結合とnull時の書込み抑止を照合する。別に保存した参照・元/コピーの結合先・成功回数・guardを、メソッド/直接経路とfull/modport型で確認する。 |
| [`interaction_wait`](../generators/interaction_wait.py) | 9 | 36 | サイズ・先頭要素・両条件を待ち、動的配列とキューの作成・拡大・縮小・削除・同サイズ置換の前後で起床時刻・回数と全要素を観測する。無関係なコンテナ変更での早期起床を区別し、既に真の場合と、型変換後のX/Zをcase等価で待つ場合も確認する。 |
| [`keywords`](../generators/keywords.py) | 5, 22 | 496 | 不正な設計。附属書Bの各予約語を``begin_keywords "1800-2023"``の下で変数名として宣言し、22.14で各版が追加する予約語もその版の``begin_keywords``の下で宣言する。ツールは拒否する必要がある |
| [`scheduling`](../generators/scheduling.py) | 4 | 325 | 既存の8ビットの書き込みを、書き込み元・待機中の別プロセス・strobe・monitorから指定の時刻とイベント領域で観測する。既存の生成テストと期待値は変更しない。 |
| [`strength`](../generators/strength.py) | 28 | 136 | 異なる強度と値を持つ二つのドライバ。wire・tri・wand・triand・wor・trior・tri0・tri1とbufifゲートを通し、`%v`で表示 |
| [`wide_paths`](../generators/wide_paths.py) | 6, 7, 11, 13 | 49 | 63・64・65・127・128・129・200ビット、2値・4値、64ビットより上のx/z、符号の有無。広い・狭い・2値の代入先、パック配列の部分選択・スライスと書き込み、連結・反復連結、幅を超えるシフト、比較、x条件の`?:`、`$bits`、関数結果、タスク入力、output・ref引数。`%h`・`%b`・`%0d`で表示 |
| [`width_sign`](../generators/width_sign.py) | 11 | 144 | 63〜1000ビットの符号付き・符号なしのオペランドと代入先。11.6〜11.8が結果の幅と符号を決める演算子 |
| [`xz_propagation`](../generators/xz_propagation.py) | 11 | 158 | 11.4でx/zの規則が定まる各演算子について、x/zを含むオペランド |

```sh
python3 tools/generator_catalog.py --update
python3 tools/generator_catalog.py --check
```
