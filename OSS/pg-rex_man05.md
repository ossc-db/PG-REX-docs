メンテナンス時の対応
====================

本章は、PostgreSQLのバックアップ取得の操作手順、アーカイブログ削除の操作手順、およびPG-REX(PrimaryまたはStandby)の停止を伴うメンテナンス(PostgreSQLのマイナーバージョンアップやハードウェアの増設等の作業)時のノードの停止、起動手順について記述します。

作業を行う際には、記述されている手順以外は行なわない様にしてください。

PostgreSQLのバックアップ
------------------------

PG-REXでは、PostgreSQL単独の場合と同じ方法で、Primaryからオンライン物理バックアップを取得することができます。しかし、バックアップ取得は、大量のI/Oを発生させる負荷の高い処理であるため、それがPrimaryで実行されるオンライン負荷に影響を与えないようにStandbyで取得することも可能です。

本節では、PostgreSQLのバックアップを取得する手順について記述します。

本節の作業は、postgresユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

### PostgreSQLのバックアップ

PostgreSQLのバックアップを取得する手順は、『PostgreSQLドキュメント』[^21]
の手順に従い実施してください。また、フェイルオーバが発生した場合は、新Primaryからバックアップを取得し直してください。旧Primaryから取得したバックアップは使用できない可能性があります。

::: {custom-style="First Paragraph"}
　
:::

【参考】

以下のようなコマンドを実行することになります。ここでは、ipaddr-replicationを使用してPrimaryからバックアップを取得しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [$ pg_basebackup \-h\ ]{custom-style="Verbatim Char"}[192.168.2.3\ ]{custom-style="italic"}[\-U repuser \-D\ ]{custom-style="Verbatim Char"}[/backupdirectory\ ]{custom-style="italic"}[\-X stream \-P]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### その他のバックアップツールを使用する場合の注意事項

ここではpg_basebackup 以外のツールを用いてデータベースのバックアップを取得して使用する際の注意事項を説明します。

::: {custom-style="First Paragraph"}
　
:::

【バックアップツールの選択】

アーカイブログが利用できるタイプのバックアップツールを選択してください。PG-REXではPostgreSQLの継続的アーカイブ機能を使用してアーカイブログを生成します。運用途中でprimary, standby両方のデータベースファイルが失われた場合であっても、継続的アーカイブが利用できるバックアップファイルがあれば、データベースファイルが失われる直前の状態のデータベースを再現することが出来ます。

::: {custom-style="First Paragraph"}
　
:::

【アーカイブログの削除】

バックアップの取得にpg-basebackup を用いformat として plain (デフォルト設定)を指定した場合[^52]に限り 、アーカイブログの削除にpg-rex_archivefile_deleteが使用できます。それ以外の場合は「コマンド直接実行の運用」の章の「アーカイブログの削除」の節にある説明を参照して、不要なアーカイブログを削除します。

::: {custom-style="First Paragraph"}
　
:::

【バックアップファイルからのリストアとリカバリ】

使用しているバックアップツールの定める手順にそって、バックアップファイルをリストアします。次いでPostgreSQL本体でリカバリすることでprimaryデータベースとして使用できるようになります。その際の注意事項は「起動と停止」の章の「Primaryの起動」の節にありますので参照してください。

::: {custom-style="page-break"}
　
:::

アーカイブログの削除
--------------------

本節では、PG-REX運用補助ツールを用いてデータベースの復旧に必要のないファイルをアーカイブディレクトリから削除する手順について記述します。

本節の作業はroot、もしくはPG-REXで管理しているDBクラスタを作成したユーザのみ実行可能です。

コマンドを直接実行してデータベースの復旧に必要のないファイルをアーカイブディレクトリから削除する手順については、『コマンド直接実行の運用』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

### PostgreSQLアーカイブログの削除

運用を続けていくにしたがってアーカイブファイルの容量は増えていくため、継続的な運用のためには適宜削除を行う必要があります。

PostgreSQLのアーカイブログ(および付随するバックアップ履歴ファイル[^22]、タイムライン履歴ファイル[^23])は、PrimaryおよびStandbyのリカバリに加え、『PostgreSQLのバックアップ』の方法で取得したバックアップからのリカバリのいずれでも必要とならない場合に削除できます。

アーカイブログを削除したいノードで、pg-rex\_archivefile\_deleteコマンドを実行することで、これらの不要なファイルを自動的に判断し、削除または移動します。

以下に、アーカイブログ削除の実行例を示します。

ここでは、保存すべき最古のベースバックアップを格納しているディレクトリを
/somewhere/basebackups/oldestとします。

::: {custom-style="page-break"}
　
:::

  ------------------------------------------------------------------------
  [$ pg\-rex_archivefile_delete \-m /somewhere/basebackups/oldest]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* 1. 実行準備 \*\*\*\*]{custom-style="Verbatim Char"}\
  [移動モードで実行します]{custom-style="red-bold"}\
  [環境設定ファイル (pg\-rex_tool.conf) を読み込みます]{custom-style="Verbatim Char"}\
  [postgres@192.168.2.2\'s password:]{custom-style="Verbatim Char"}\
  [パスワードが入力されました]{custom-style="Verbatim Char"}\
  [両ノードの名前を取得します]{custom-style="Verbatim Char"}\
  [cib.xml ファイルを読み込みます]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* 2. WAL ファイル名の取得 \*\*\*\*]{custom-style="Verbatim Char"}\
  [指定されたバックアップからリカバリを行うために必要な最初の WAL ファイル名を取得します]{custom-style="Verbatim Char"}\
  [\"00000051000000010000003A\"]{custom-style="Verbatim Char"}\
  [自身のノード \"pgrex01\" の現時点の PGDATA \"/dbfp/pgdata/data \"からリカバリに必要な最初の WAL ファイル名を取得します]{custom-style="Verbatim Char"}\
  [\"00000052000000010000003E\"]{custom-style="Verbatim Char"}\
  [相手のノード \"pgrex02\" の現時点の PGDATA \"/dbfp/pgdata/data \"からリカバリに必要な最初の WAL ファイル名を取得します]{custom-style="Verbatim Char"}\
  [\"00000052000000010000003D\"]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* 3. 削除基準の算出 \*\*\*\*]{custom-style="Verbatim Char"}\
  [削除基準を \"00000051000000010000003A\" としました]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* 4. アーカイブログの削除 \*\*\*\*]{custom-style="Verbatim Char"}\
  [削除対象のリストに \"0000004F0000000100000035.00000020.backup\"を追加します]{custom-style="Verbatim Char"}\
  [削除対象のリストに \"0000004D0000000100000034\" を追加します]{custom-style="Verbatim Char"}\
  [:(略)]{custom-style="Verbatim Char"}\
  [移動先ディレクトリ \"/dbfp/pgarch/arc1/20211119_150226\"を作成しました]{custom-style="Verbatim Char"}\
  [\-\- 移動 \-\- 0000004F0000000100000035.00000020.backup]{custom-style="Verbatim Char"}\
  [:(略)]{custom-style="Verbatim Char"}\
  [アーカイブログの移動に成功しました]{custom-style="red-bold"}\
  [移動モード実行のため、移動したファイルは\"/dbfp/pgarch/arc1/20211119_150226\" に格納されています]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

この実行例ではコマンドに -mオプションを指定しているため、作業の終了後には
/dbfp/pgarch/arc1/20211119\_150226
ディレクトリに不要となったファイルが格納されています。これを削除するか別のディスク等に移動させるなどすることで作業は完了します。

-m オプションの代わりに
-r オプションを指定するとツール自身がファイルを削除します。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

計画的なノード切り替え
------------------

PrimaryとStandbyという2つのノードの役割を入れ替えることを、PG-REXではノード切り替えまたはスイッチオーバと呼びます。ここでは、PG-REX運用補助ツールのスイッチオーバ機能(pg-rex\_switchover)を使用したノード切り替え手順を説明します。

本節の作業は、rootユーザで行います。

運用補助ツールを使用せずに直接コマンドを実行してノード切り替えを実施したい場合は、『コマンド直接実行の運用』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

### ノード切り替え

運用補助ツールを使用したノード切り替えは、PG-REXのPrimaryとStandbyのどちらのノードでも実施することができます。以下に、pgrex01でノード切り替えを実行する場合の手順を示します。

::: {custom-style="First Paragraph"}
　
:::

(1) pg-rex\_switchoverコマンドを実行します。パスワードの入力要求に対して、相手ノードのrootユーザのパスワードを入力してください。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pg\-rex_switchover]{custom-style="Verbatim Char"}\
  [root@192.168.2.2\'s password:]{custom-style="Verbatim Char"}\
  [パスワードが入力されました]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) 表示された現在およびノード切り替え後のHAクラスタ状態を確認します。ノード切り替えを実行しても良い場合は\[y\]を入力します。

    なお、ノード切り替え中は可用性が保証されないことに注意してください。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\*\*\*\* 実行準備 \*\*\*\*]{custom-style="Verbatim Char"}\
  [1. 環境設定ファイル (pg-rex_tools.conf)の読み込みと両ノードの名前を取得]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. 現在およびノード切り替え後のHAクラスタ状態を確認]{custom-style="Verbatim Char"}\
  \
  [\[ 現在 / ノード切り替え後のHAクラスタ状態 \]]{custom-style="Verbatim Char"}\
  [Primary : pgrex01 \-> pgrex02]{custom-style="Verbatim Char"}\
  [Standby : pgrex02 \-> pgrex01]{custom-style="red-bold"}\
  \
  [ノード切り替え中は可用性が保証されません]{custom-style="Verbatim Char"}\
  [ノード切り替えを実行してもよろしいでしょうか？\ (y/N)\ ]{custom-style="Verbatim Char"}[y]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(3) ノード切り替えが完了するまで待機し、コマンドが正常に完了したことを確認します。異常終了した場合は、HAクラスタ状態が不確定であり、データベースサービスが停止している可能性があります。この場合、元の状態への復旧は自動で実施されません。『故障対応』に従い、手動復旧を試みてください。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\*\*\*\* ノード切り替えを実行 \*\*\*\*]{custom-style="Verbatim Char"}\
  [3. Pacemaker の監視を停止]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [4. Primary (pgrex01) の PostgreSQL を停止]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [5. Pacemaker の監視を再開しノード切り替えを実行]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [6. pgrex02 が新 Primary になったことを確認]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* pgrex02 が Primary として起動しました \*\*\*\*]{custom-style="Verbatim Char"}\
  \
  [7. pgrex01 の Pacemaker を停止]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [8. pgrex01 で Standby を起動]{custom-style="Verbatim Char"}\
  [00000011000000000000000C]{custom-style="Verbatim Char"}\
  [00000012000000000000000E]{custom-style="Verbatim Char"}\
  [00000013.history]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\* pgrex01 が Standby として起動しました \*\*\*\*]{custom-style="Verbatim Char"}\
  \
  [\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*]{custom-style="red-bold"}\
  [\*\*\*\* ノード切り替えが正常に完了しました \*\*\*\*]{custom-style="red-bold"}\
  [\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*]{custom-style="red-bold"}\
  \
  [\[ 現在のHAクラスタ状態 \]]{custom-style="red-bold"}\
  [\ Primary : pgrex02]{custom-style="red-bold"}\
  [\ Standby : pgrex01]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【注意】

Pacemakerの監視を停止中(上記の4～6の間)にコマンドが異常終了した場合は、Pacemakerの監視が停止している可能性があるため、pcs statusコマンドを実行しHAクラスタ状態を確認してください。pcs statusコマンドの実行結果のリソース情報表示部に\"unmanaged\"が表示されている場合はPacemakerの監視が停止しています。Pacemakerの監視が停止している場合は、Pacemakerの監視を再開してください。

Pacemakerの監視を再開するには以下のコマンドを実行します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs property set maintenance\-mode=]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

計画的なメンテナンスのためのノードの停止、起動
----------------------------------------------

本節では、PrimaryおよびStandbyの計画されたメンテナンス(PostgreSQLのマイナーバージョンアップやハードウェアの増設等の作業)を実施する時のノードの停止、メンテナンス後の起動の操作手順を記述します。

本節の作業は、rootユーザで実行します。

::: {custom-style="First Paragraph"}
　
:::

### メンテナンスのためのノードの停止

メンテナンス対象のノードを停止する手順を以下に示します。

::: {custom-style="First Paragraph"}
　
:::

(1) メンテナンス対象のノードの停止

    メンテナンス対象のノードの運用を停止します。停止手順については、『起動と停止』の章を参照してください。

::: {custom-style="page-break"}
　
:::

(2) データベースサービス継続の確認

    起動中のノードでデータベースサービスが継続していることを、pcs statusコマンドを実行して確認します。

    -   ノード情報表示部で、起動中のノードの状態が\"Online\"になっていること。
    -   リソース情報表示で、PG-REXリソース(pgsql-clone)に、\"Master pgrex02\"のように起動中のノードが表示されていること。
    -   リソース情報表示で、全てのIPaddr2リソース(ipaddr-primary、ipaddr-standby、ipaddr-replication)が、起動中のノードで稼働していること。

    以下に、pgrex01停止後、pgrex02で確認した場合の例を示します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="red-bold"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### メンテナンス後のノードの起動

メンテナンス作業終了後は、メンテナンスのために停止したノードをStandbyとして起動します。起動手順については、『起動と停止』の章を参照してください。

起動後、PrimaryとStandbyを切り替えたい場合は、『計画的なノード切り替え』に従い切り替えます。

