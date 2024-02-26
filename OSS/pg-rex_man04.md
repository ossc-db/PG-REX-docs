起動と停止 {#sec:起動と停止}
==========

本章では、PG-REX運用補助ツールを用いてPrimaryとStandbyの起動・停止方法について説明します。

本章の作業はrootユーザで行います。

コマンドを直接実行してPrimaryとStandbyの起動・停止をする場合は、『[@sec:コマンド直接実行の運用](#sec:コマンド直接実行の運用) [コマンド直接実行の運用](#コマンド直接実行の運用)』を参照してください。

PG-REXの起動 {#sec:PG-REXの起動}
----------

PG-REXの起動は、一方のノードでPrimaryを起動させ、起動完了後、もう一方のノードでStandbyを起動させます。どちらのノードをPrimary、Standbyとして稼働させるかは、ユーザが決定します。

-   Primaryの起動手順については、『[@sec:Primaryの起動](#sec:Primaryの起動) [Primaryの起動](#sec:Primaryの起動)』を参照してください。
-   Standbyの起動手順については、『[@sec:Standbyの起動](#sec:Standbyの起動) [Standbyの起動](#sec:Standbyの起動)』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

Primaryの起動 {#sec:Primaryの起動}
------------

本節では、Primaryの起動手順を説明します。

::: {custom-style="First Paragraph"}
　
:::

(1) どのノードをPrimaryとして起動するか決定します。
    PG-REXでは、最新のDBデータを持つノードをPrimaryとして起動しなければなりません。古いDBデータを持つノードをPrimaryとして起動すると、その古い分だけDBデータは失われてしまいます。

    以下は、Primaryとして起動するノードを決めるときの考え方の例です。

    ::: {custom-style="First Paragraph"}
    　
    :::

    -   DBクラスタが片方のノードのみに存在し、そのDBクラスタを使ってPG-REXを起動する場合(初めてPrimaryを起動する場合を含む)は、DBクラスタが存在するノードをPrimaryとして起動する。
    -   DBクラスタが両ノードに存在する場合は、直前までPrimaryとして稼働していたノードをPrimaryとして起動する。
    -   既存のDBクラスタを使わず(もしくは既存のDBクラスタが壊れている)、以前に取得したベースバックアップからPG-REXを起動する場合は、そのベースバックアップを展開したノードをPrimaryとして起動する。

    以降の手順では、pgrex01をPrimaryとして起動します。

::: {custom-style="page-break"}
　
:::

(2) ベースバックアップからPrimaryを起動する場合に限り、pgrex01でPostgreSQL単体のアーカイブリカバリを行います。アーカイブリカバリの手順については、『PostgreSQLドキュメント』を参照してください。アーカイブリカバリが完了したら、PostgreSQLを停止します。

    本作業のみpostgresユーザで行う必要があります。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [$ pg_ctl start]{custom-style="Verbatim Char"}\
  [サーバの起動完了を待っています\.\.\.\.]{custom-style="Verbatim Char"}\
  [：(略)]{custom-style="Verbatim Char"}\
  [完了]{custom-style="Verbatim Char"}\
  [サーバ起動完了]{custom-style="red-bold"}\
  [$ pg_ctl stop]{custom-style="Verbatim Char"}\
  [サーバ停止処理の完了を待っています\.\.\.\.完了]{custom-style="Verbatim Char"}\
  [サーバは停止しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【注意】

PG-REXでは、アーカイブリカバリをさせながらPrimaryを起動することを推奨しません。これは、アーカイブリカバリにより起動に時間がかかり、Pacemakerによって起動失敗とみなされてしまう可能性があるからです。そのため、Primaryでアーカイブリカバリを行う場合は、Pacemaker経由ではなく、まずはPostgreSQL単体で起動させるようにしてください。アーカイブリカバリの完了後、PostgreSQLを停止させた上で、Primaryの起動の手順を行います。これにより、Primary起動時のアーカイブリカバリは必要なくなるため、Primaryの起動に時間がかかることはありません。

また、PG-REXでリカバリを実施する場合は必ず最新の状態までリカバリされます。
アーカイブリカバリを行う際にユーザが追加した設定は、アーカイブリカバリ終了後にすべて削除してください。

::: {custom-style="First Paragraph"}
　
:::

(3) pgrex01で起動禁止フラグのファイルが存在する場合削除します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# rm /var/lib/pgsql/tmp/PGSQL.lock]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(4) Primaryを起動します。

::: {custom-style="First Paragraph"}
　
:::

【初回もしくは新しいリソース定義xmlファイルを反映させる場合】

Primary初回起動時、もしくは既存のPacemakerの設定をクリアして新しいリソース定義xmlファイルを反映させる場合は、リソース定義xmlファイルを指定して、Primaryを起動します。

この手順でPrimaryを起動した場合、pcsコマンド等で直接設定を変更した項目は初期化されます。 必要に応じて再設定してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pg\-rex_primary_start pm_pcsgen_env.xml]{custom-style="Verbatim Char"}\
  [root@192.168.2.2\'s password:]{custom-style="Verbatim Char"}\
  [パスワードが入力されました]{custom-style="Verbatim Char"}\
  [1. Pacemaker および Corosync が停止していることを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. 稼働中の Primary が存在していないことを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [3. 起動禁止フラグの存在を確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [既に HAクラスタ があります]{custom-style="Verbatim Char"}\
  [再作成しても宜しいでしょうか？\ (y/N)\ ]{custom-style="Verbatim Char"}[y]{custom-style="red-bold"}\
  [4. HAクラスタ の破棄]{custom-style="Verbatim Char"}\
  [Warning: Unable to load CIB to get guest and remote nodes from it, those nodes will not be deconfigured.]{custom-style="Verbatim Char"}\
  [：(略)]{custom-style="Verbatim Char"}\
  [pgrex01: Successfully destroyed cluster]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [5. HAクラスタ の作成]{custom-style="Verbatim Char"}\
  [Destroying cluster on hosts: \'pgrex01\', \'pgrex02\'...]{custom-style="Verbatim Char"}\
  [：(略)]{custom-style="Verbatim Char"}\
  [Cluster has been successfully set up.]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [6. Pacemaker 起動]{custom-style="Verbatim Char"}\
  [Starting Cluster...]{custom-style="Verbatim Char"}\
  [Waiting for node(s) to start...]{custom-style="Verbatim Char"}\
  [Started]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [7. リソース定義 xml ファイルの反映]{custom-style="Verbatim Char"}\
  [CIB updated]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [Warning: If node(s) \'pgrex02\' are not powered off or they do have access to shared resources, data corruption and/or cluster failure may occur]{custom-style="Verbatim Char"}\
  [Warning: If node \'pgrex02\' is not powered off or it does have access to shared resources, data corruption and/or cluster failure may occur]{custom-style="Verbatim Char"}\
  [Quorum unblocked]{custom-style="Verbatim Char"}\
  [Waiting for nodes canceled]{custom-style="Verbatim Char"}\
  [8. Primary の起動確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [ノード(pgrex01)が Primary として起動しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【2回目以降の場合】

Primaryを起動します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pg\-rex_primary_start]{custom-style="Verbatim Char"}\
  [root@192.168.2.2\'s password:]{custom-style="Verbatim Char"}\
  [パスワードが入力されました]{custom-style="Verbatim Char"}\
  [1. Pacemaker および Corosync が停止していることを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. 稼働中の Primary が存在していないことを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [3. Primary として稼働することが出来るかを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [4. 起動禁止フラグの存在を確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [5. Pacemaker 起動]{custom-style="Verbatim Char"}\
  [Starting Cluster...]{custom-style="Verbatim Char"}\
  [Waiting for node(s) to start...]{custom-style="Verbatim Char"}\
  [Started]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [Warning: If node(s) \'pgrex02\' are not powered off or they do have access to shared resources, data corruption and/or cluster failure may occur]{custom-style="Verbatim Char"}\
  [Warning: If node \'pgrex02\' is not powered off or it does have access to shared resources, data corruption and/or cluster failure may occur]{custom-style="Verbatim Char"}\
  [Quorum unblocked]{custom-style="Verbatim Char"}\
  [Waiting for nodes canceled]{custom-style="Verbatim Char"}\
  [6. Primary の起動確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [ノード(pgrex01)が Primary として起動しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【注意】

以下のいずれかのGUCを変更した後にPrimary起動を試みるとPostgreSQLが起動しないことがあります。新しい設定値は、変更前の設定値以上にする必要があるためです。

-   max_connections
-   max_worker_processes
-   max_prepared_transactions
-   max_locks_per_transaction

より詳しい説明については、PostgreSQLドキュメント[^20]を参照してください。

新しい設定値が変更前の設定値未満の場合、PostgreSQLのみを一度起動・終了する必要があります。postgresユーザでpg\_ctl startとpg\_ctl stopを実行してください。

::: {custom-style="First Paragraph"}
　
:::

(5) pgrex02のSTONITH履歴をクリアします。

    Primary起動時は、片方のノードのみの起動となるため、正常に起動した場合でも、pcs statusコマンドを実行すると、Fencing Historyに情報が表示されます。
    そのため、その履歴をクリアします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# stonith_admin -c -H pgrex02]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

Standbyの起動 {#sec:Standbyの起動}
-----------

本節では、Standbyの起動手順を説明します。以降の手順では、pgrex02をStandbyとして起動します。

::: {custom-style="First Paragraph"}
　
:::

(1) pgrex02で起動禁止フラグのファイルが存在する場合削除します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# rm /var/lib/pgsql/tmp/PGSQL.lock]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) pgrex02でStandbyを起動します。同期する必要の無い不要なアーカイブログが多い場合は、Standbyの起動の前にアーカイブログの削除を行なってください。アーカイブログの削除は『[@sec:PostgreSQLアーカイブログの削除](#sec:PostgreSQLアーカイブログの削除) [PostgreSQLアーカイブログの削除](#sec:PostgreSQLアーカイブログの削除)』を参照してください。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pg\-rex_standby_start]{custom-style="Verbatim Char"}\
  [root@192.168.2.1\'s password:]{custom-style="Verbatim Char"}\
  [パスワードが入力されました]{custom-style="Verbatim Char"}\
  [1. Pacemaker および Corosync が停止していることを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. 稼働中の Primary が存在していることを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [3. 起動禁止フラグが存在しないことを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(3) 起動方法を選択します。

    以下の手順では、ベースバックアップを取得する場合を示します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [4. DB クラスタの状態を確認]{custom-style="Verbatim Char"}\
  [4.1 現在のDBクラスタのまま起動が可能か確認]{custom-style="Verbatim Char"}\
  [DB クラスタが存在していません]{custom-style="Verbatim Char"}\
  [\.\.\.\[NG\]]{custom-style="red-bold"}\
  [4.2 巻き戻しを実行することで起動が可能か確認]{custom-style="Verbatim Char"}\
  [DB クラスタが存在していません]{custom-style="Verbatim Char"}\
  [\.\.\.\[NG\]]{custom-style="red-bold"}\
  [4.3 ベースバックアップを取得することが可能か確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [以下の方法で起動が可能です]{custom-style="Verbatim Char"}\
  [b) ベースバックアップを取得してStandbyを起動]{custom-style="Verbatim Char"}\
  [q) Standbyの起動を中止する]{custom-style="Verbatim Char"}\
  [起動方法を選択してください(b/q)\ ]{custom-style="Verbatim Char"}[b]{custom-style="red-bold"}\
  [5. IC\-LAN が接続されていることを確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [6. Primary からベースバックアップ取得]{custom-style="Verbatim Char"}\
  [22631/22631 kB (100%), 1/1 テーブル空間]{custom-style="Verbatim Char"}\
  [NOTICE:  all required WAL segments have been archived]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [7. Primary のアーカイブディレクトリと同期]{custom-style="Verbatim Char"}\
  [000000010000000000000002.partial]{custom-style="Verbatim Char"}\
  [00000002.history]{custom-style="Verbatim Char"}\
  [000000020000000000000003.00000028.backup]{custom-style="Verbatim Char"}\
  [000000010000000000000001]{custom-style="Verbatim Char"}\
  [000000020000000000000002]{custom-style="Verbatim Char"}\
  [000000020000000000000003]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [8. Standby の起動 (アーカイブリカバリ対象 WAL セグメント数: 1)]{custom-style="Verbatim Char"}\
  [Starting Cluster...]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [9. Standby の起動確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [ノード(pgrex02)が Standby として起動しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

PG-REXの停止 {#sec:PG-REXの停止}
----------

PG-REXを停止するには、Standbyを停止させ、Standbyの停止完了後にPrimaryを停止させます。

Primaryから停止した場合、フェイルオーバが発生しますので、ご注意ください。

-   Primaryの停止手順については、『[@sec:Primaryの停止](#sec:Primaryの停止) [Primaryの停止](#sec:Primaryの停止)』を参照してください。
-   Standbyの停止手順については、『[@sec:Standbyの停止](#sec:Standbyの停止) [Standbyの停止](#sec:Standbyの停止)』を参照してください。

この手順でPG-REXを停止させた場合、次にPG-REXを起動するときには、Primaryからのベースバックアップの取得は必要ありません。

::: {custom-style="First Paragraph"}
　
:::

Standbyの停止 {#sec:Standbyの停止}
-----------

本節では、Standbyの停止手順を説明します。

本作業は停止対象のノードで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) Standbyを停止します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pg\-rex_stop]{custom-style="Verbatim Char"}\
  [Standby を停止します]{custom-style="Verbatim Char"}\
  [1. Pacemaker 停止]{custom-style="Verbatim Char"}\
  [Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [Stopping Cluster (corosync)...]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. Pacemaker 停止確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [PG\-REX の Standby (pgrex02)を停止しました]{custom-style="red-bold"}


  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

Primaryの停止 {#sec:Primaryの停止}
------------

本節では、Primaryの停止手順を説明します。Standby稼働中にPrimaryを停止した場合、フェイルオーバが発生することに注意してください。

本作業は停止対象のノードで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) Primaryを停止します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pg\-rex_stop]{custom-style="Verbatim Char"}\
  [Primary を停止します]{custom-style="Verbatim Char"}\
  [1. Pacemaker 停止]{custom-style="Verbatim Char"}\
  [Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [Stopping Cluster (corosync)...]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. Pacemaker 停止確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [PG\-REX の Primary (pgrex01)を停止しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【注意】

Standby稼働中の場合、以下の問い合わせが出力されます。フェイルオーバしても問題がなければ「y」を入力してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Primary を停止します]{custom-style="Verbatim Char"}\
  [Standby がまだ起動しています]{custom-style="Verbatim Char"}\
  [ノード切り替えが目的の場合は pg\-rex_switchover コマンドの使用を推奨します]{custom-style="Verbatim Char"}\
  [今停止すると F/O しますが本当に停止しても宜しいですか？ (y/N)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

PostgreSQL停止中のノードの停止 {#sec:PostgreSQL停止中のノードの停止}
--------------------------

本節では、PostgreSQL停止中(Stopped)のノードのPacemakerの停止手順を説明します。主に、運用中に故障が発生した後、復旧するための手順の一つとして行われます。

本作業は停止対象のノードで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) PostgreSQL停止中(Stopped)のノードのPacemakerを停止します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pg\-rex_stop]{custom-style="Verbatim Char"}\
  [PostgreSQL の状態を確認できませんでした]{custom-style="Verbatim Char"}\
  [Pacemaker を停止します]{custom-style="Verbatim Char"}\
  [1. Pacemaker 停止]{custom-style="Verbatim Char"}\
  [Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [Stopping Cluster (corosync)...]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [2. Pacemaker 停止確認]{custom-style="Verbatim Char"}\
  [\.\.\.\[OK\]]{custom-style="red-bold"}\
  [ノード(pgrex01)で Pacemaker を停止しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------
