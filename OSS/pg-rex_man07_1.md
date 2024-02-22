コマンド直接実行の運用 {#sec:コマンド直接実行の運用}
======================

本章では、コマンドを直接実行して運用する手順を説明します。PG-REX運用補助ツールを用いて運用する場合は、『[@sec:起動と停止](#sec:起動と停止) [起動と停止](#sec:起動と停止)』および『[@sec:メンテナンス時の対応](#sec:メンテナンス時の対応) [メンテナンス時の対応](#sec:メンテナンス時の対応)』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

起動と停止
----------

本節では、コマンドを直接実行して起動と停止を行う手順を説明します。

::: {custom-style="First Paragraph"}
　
:::

### PG-REXの起動

PG-REXの起動は、一方のノードでPrimaryを起動させ、起動完了後、もう一方のノードでStandbyを起動させます。どちらのノードをPrimary、Standbyとして稼働させるかは、ユーザが決定します。

PrimaryおよびStandbyの起動手順については、以降の各項を参照してください。

::: {custom-style="First Paragraph"}
　
:::

### Primaryの起動

本節では、Primaryの起動手順を説明します。

::: {custom-style="First Paragraph"}
　
:::

(1) どのノードをPrimaryとして起動するか決定します。

    PG-REXでは、最新のDBデータを持つノードをPrimaryとして起動しなければなりません。古いDBデータを持つノードをPrimaryとして起動すると、その古い分だけDBデータは失われてしまいます。

    以下は、Primaryとして起動するノードを決めるときの考え方の例です。

    -   DBクラスタが片方のノードのみに存在し、そのDBクラスタを使ってPG-REXを起動する場合(初めてPrimaryを起動する場合を含む)は、DBクラスタが存在するノードをPrimaryとして起動する。
    -   DBクラスタが両方のノードに存在する場合は、直前までPrimaryとして稼働していたノードをPrimaryとして起動する。
    -   既存のDBクラスタを使わず(もしくは既存のDBクラスタが壊れている)、以前に取得したベースバックアップからPG-REXを起動する場合は、そのベースバックアップを展開したノードをPrimaryとして起動する。

::: {custom-style="page-break"}
　
:::

以降の手順では、pgrex01をPrimaryとして起動します。

::: {custom-style="First Paragraph"}
　
:::

(2) pgrex01およびpgrex02で、Pacemakerが停止していることを確認します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [Error: error running crm_mon, is pacemaker running?]{custom-style="red-bold"}\
  [\ \ error:\ Could\ not\ connect\ to\ launcher:\ Connection refused]{custom-style="red-bold"}\
  [\ \ crm_mon: Error: cluster is not available on this node]{custom-style="red-bold"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) ベースバックアップからPrimaryを起動する場合に限り、pgrex01でPostgreSQL単体のアーカイブリカバリを行います。

    アーカイブリカバリの手順については、『PostgreSQLドキュメント』を参照してください。アーカイブリカバリが完了したら、PostgreSQLを停止します。

    本作業はpostgresユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [$ pg_ctl start]{custom-style="Verbatim Char"}\
  [サーバの起動完了を待っています\.\.\.\.]{custom-style="red-bold"}\
  [：(略)]{custom-style="Verbatim Char"}\
  [完了]{custom-style="red-bold"}\
  [サーバ起動完了]{custom-style="red-bold"}\
  [$ pg_ctl stop]{custom-style="Verbatim Char"}\
  [サーバ停止処理の完了を待っています\.\.\.\.完了]{custom-style="red-bold"}\
  [サーバは停止しました]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【注意】

PG-REXでは、アーカイブリカバリをさせながらPrimaryを起動することを推奨しません。これは、アーカイブリカバリにより起動に時間がかかり、Pacemakerによって起動失敗とみなされてしまう可能性があるからです。そのため、Primaryでアーカイブリカバリを行う場合は、Pacemaker経由ではなく、まずはPostgreSQL単体で起動させるようにしてください。アーカイブリカバリの完了後、PostgreSQLを停止させた上で、Primaryの起動の手順を行います。これにより、Primary起動時のアーカイブリカバリは必要なくなるため、Primaryの起動に時間がかかることはありません。

また、PG-REXでリカバリを行う場合は、必ず最新の状態となります。

アーカイブリカバリを行う際にユーザが追加した設定は、アーカイブリカバリ終了後にすべて削除してください。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

(4) pgrex01で起動禁止フラグのファイルが存在する場合は削除します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# rm /var/lib/pgsql/tmp/PGSQL.lock]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(5) 初回起動時、もしくは新しいリソース定義xmlファイルを反映させる場合、HAクラスタを作成します。すでにHAクラスタが存在する場合は、既存のHAクラスタを削除します。

    HAクラスタの作成には、HAクラスタ名、それぞれのノードのホスト名とインターコネクトLANのIPアドレス2つのセットを2組指定します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs cluster destroy \-\-all]{custom-style="Verbatim Char"}\
  [Warning: Unable to load CIB to get guest and remote nodes from it, those nodes will not be deconfigured.]{custom-style="Verbatim Char"}\
  [pgrex01: Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [pgrex02: Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [pgrex01: Successfully destroyed cluster]{custom-style="Verbatim Char"}\
  [pgrex02: Successfully destroyed cluster]{custom-style="Verbatim Char"}\
  \
  [# pcs cluster setup pgrex_cluster pgrex01 addr=192.168.1.1 addr=192.168.3.1 pgrex02 addr=192.168.1.2 addr=192.168.3.2]{custom-style="Verbatim Char"}\
  [Destroying cluster on hosts: 'pgrex01', 'pgrex02'...]{custom-style="Verbatim Char"}\
  [pgrex02: Successfully destroyed cluster]{custom-style="Verbatim Char"}\
  [pgrex01: Successfully destroyed cluster]{custom-style="Verbatim Char"}\
  [Requesting remove 'pcsd settings' from 'pgrex01', 'pgrex02']{custom-style="Verbatim Char"}\
  [pgrex01: successful removal of the file 'pcsd settings']{custom-style="Verbatim Char"}\
  [pgrex02: successful removal of the file 'pcsd settings']{custom-style="Verbatim Char"}\
  [Sending 'corosync authkey', 'pacemaker authkey' to 'pgrex01', 'pgrex02']{custom-style="Verbatim Char"}\
  [pgrex02: successful distribution of the file 'corosync authkey']{custom-style="Verbatim Char"}\
  [pgrex02: successful distribution of the file 'pacemaker authkey']{custom-style="Verbatim Char"}\
  [pgrex01: successful distribution of the file 'corosync authkey']{custom-style="Verbatim Char"}\
  [pgrex01: successful distribution of the file 'pacemaker authkey']{custom-style="Verbatim Char"}\
  [Sending 'corosync.conf' to 'pgrex01', 'pgrex02']{custom-style="Verbatim Char"}\
  [pgrex01: successful distribution of the file 'corosync.conf']{custom-style="Verbatim Char"}\
  [pgrex02: successful distribution of the file 'corosync.conf']{custom-style="Verbatim Char"}\
  [Cluster has been successfully set up.]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(6) pgrex01でPrimaryを起動します。

    本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs cluster start]{custom-style="Verbatim Char"}\
  [Starting Cluster...]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(7) pgrex01のPacemakerが起動したことを確認します。

    本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [\ \*\ Last change:\ \ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ by\ hacluster\ via\ crmd\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.16.2]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

Onlineになるには数十秒の時間を要する場合があります。

::: {custom-style="First Paragraph"}
　
:::

【注意】

以下のWARNINGS表示はSTONITH設定が行われていないことによるものですので、現段階では問題ありません。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [WARNINGS: No stonith devices and stonith-enabled is not false]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(8) 初回起動時、もしくは新しいリソース定義xmlファイルを反映させる場合、リソース定義xmlファイルを反映させます。

    pgrex01でリソース定義xmlファイルを反映させるコマンドを実行します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs cluster cib\-push pm_pcsgen_env.xml]{custom-style="Verbatim Char"}\
  [CIB updated]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(9) quorumの解除をします。

    quorumを解除するコマンドを実行します。
    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs quorum unblock \-\-force]{custom-style="Verbatim Char"}\
  [Node: pgrex02 confirmed fenced]{custom-style="Verbatim Char"}\
  [Quorum unblocked]{custom-style="Verbatim Char"}\
  [Waiting for nodes canceled]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::
    
(10) pgrex02のSTONITH履歴をクリアします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# stonith_admin -c -H pgrex02]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------
  
::: {custom-style="page-break"}
　
:::

(11) pgrex01でpcs status \-\-full コマンドを実行し、PrimaryのPacemakerが正常に起動したことを確認します。

     本作業はrootユーザで行います。

     ::: {custom-style="First Paragraph"}
     　
     :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [\ \*\ Last change:\ \ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ by\ hacluster\ via\ crmd\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.16.2]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):]{custom-style="Verbatim Char"}[\ \ Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ storage-mon-clone\ [storage-mon]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ storage-mon\	(ocf::heartbeat:storage-mon):]{custom-style="Verbatim Char"}[\	Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  \
  [Node\ Attributes:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):]{custom-style="red-bold"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1000]{custom-style="red-bold"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ LATEST]{custom-style="red-bold"}\
  [\ \ \*\ pgsql\-master\-baseline]{custom-style="Verbatim Char"}\	\	\	[:\ 0000000005000060]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ PRI]{custom-style="red-bold"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="red-bold"}\
  \
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::


### Standbyの起動

本節では、Standbyの起動手順を説明します。以降の手順では、pgrex02をStandbyとして起動します。

::: {custom-style="First Paragraph"}
　
:::

(1) pgrex01でPrimaryが稼働中であること、およびpgrex02でPacemakerが停止していることを確認します。

    pgrex02でPacemakerが稼働中の場合はPacemakerを停止します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [Error: error running crm_mon, is pacemaker running?]{custom-style="red-bold"}\
  [\ \ error:\ Could\ not\ connect\ to\ launcher:\ Connection refused]{custom-style="red-bold"}\
  [\ \ crm_mon: Error: cluster is not available on this node]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) 以下のいずれかの場合に限り、Primaryから新たにベースバックアップを取得します。

    -   pgrex02が初回起動時の場合

    -   pgrex02にDBクラスタ(または展開されたベースバックアップ)が存在しない場合

    -   pgrex02に起動禁止フラグのファイル(/var/lib/pgsql/tmp/PGSQL.lock)が存在する場合

        起動禁止フラグのファイルが存在するということは、前回停止時(異常終了も含む)にpgrex02がPrimaryとして稼働していたことを意味します。このようなノードをStandbyとして起動する場合(例えば、異常終了した旧Primaryのノードを、フェイルオーバ後に再組み込みする場合)は、Primaryからベースバックアップを取得する必要があります。一方、例えば、Standbyとして稼働していたノードを、停止後に再び起動する場合は、起動禁止フラグのファイルが存在せず、ベースバックアップの取得は不要となります。

    -   pgrex02に存在するDBクラスタが非常に古い場合

        Standbyを長期間停止していたなどで、pgrex02のDBクラスタがpgrex01のDBクラスタと比べて非常に古い場合。この場合、pgrex02のDBクラスタをそのまま使用するとリカバリが大量に必要になります。

    -   pgrex01で稼働中のPrimaryにレプリケーション接続ができない場合

        たとえば、システムIDが異なる、タイムライン履歴が一致しないなどの場合。

    ::: {custom-style="page-break"}
    　
    :::

    Primaryからバックアップを取得しなければならない場合は、『PostgreSQLドキュメント』を参考に、pgrex01からバックアップを取得し、pgrex02の$PGDATAに展開します。バックアップの方法は、システムの要件に応じて決める必要があります。例えば、pgrex02において、postgresユーザで以下の操作を行い、バックアップを取得します。pg_basebackupコマンドの詳細は、『PostgreSQLドキュメント』を参照してください。

    本作業はpostgresユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [$ rm \-rf \$PGDATA]{custom-style="Verbatim Char"}\
  [$ rm \-rf /dbfp/pgwal/pg_wal]{custom-style="Verbatim Char"}\
  [$ pg_basebackup \-h 192.168.2.3 \-U repuser \-D $PGDATA \-X none \-P]{custom-style="Verbatim Char"}\
  [70762/70762 kB (100%), 1/1 テーブル空間]{custom-style="Verbatim Char"}\
  [NOTICE:  all required WAL segments have been archived]{custom-style="Verbatim Char"}\
  \
  [※ \-hにはレプリケーション受付用の仮想IPアドレス]{custom-style="Verbatim Char"}\
  [\ \ \-Uにはレプリケーションユーザを指定]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) pgrex01からpgrex02へアーカイブディレクトリを同期します。

    本作業はpostgresユーザで行います。

    アーカイブディレクトリの同期は必ずPrimaryからStandbyに行ってください。誤ってStandbyからPrimaryに同期すると、DBデータの一部が失われる可能性があります。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [$ rsync \-av \-\-size\-only 192.168.2.3:/dbfp/pgarch/arc1/ /dbfp/pgarch/arc1/]{custom-style="Verbatim Char"}\
  [postgres@192.168.2.3's password:]{custom-style="Verbatim Char"}\
  [receiving incremental file list]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [sent 1,434 bytes  received 889,422,925 bytes  61,339,610.97 bytes/sec]{custom-style="Verbatim Char"}\
  [total size is 889,200,754  speedup is 1.00]{custom-style="Verbatim Char"}\
  \
  [※ 接続先はレプリケーション受付用の仮想IPアドレス]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(4) pgrex02で起動禁止フラグのファイルが存在する場合は削除します。

    本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# rm /var/lib/pgsql/tmp/PGSQL.lock]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(5) pgrex02でStandbyを起動します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs cluster start]{custom-style="Verbatim Char"}\
  [Starting Cluster...]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(6) pgrex02でpcs status \-\-full コマンドを実行し、StandbyのPacemakerが正常に起動したことを確認します。

    本作業はrootユーザで行います。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [\ \*\ Last change:\ \ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ by\ hacluster\ via\ crmd\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.16.2]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.16.2]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Slave\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):]{custom-style="Verbatim Char"}[\ \ Started\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ storage-mon-clone\ [storage-mon]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ storage-mon\	(ocf::heartbeat:storage-mon):\	Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ storage-mon\	(ocf::heartbeat:storage-mon):]{custom-style="Verbatim Char"}[\	Started\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node\ Attributes:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1000]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ LATEST]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-master\-baseline]{custom-style="Verbatim Char"}\	\	\	[:\ 0000000005000060]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ PRI]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex02\ (2):]{custom-style="red-bold"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 100]{custom-style="red-bold"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ STREAMING|SYNC]{custom-style="red-bold"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ HS:sync]{custom-style="red-bold"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="red-bold"}\
  \
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(7) corosync\-cfgtoolコマンドで、各インターコネクトLANの状態が「localhost」、「connected」であることを確認します。

    本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# corosync\-cfgtool \-s]{custom-style="Verbatim Char"}\
  [Local node ID 1, transport knet]{custom-style="Verbatim Char"}\
  [LINK ID 0 udp]{custom-style="Verbatim Char"}\
  \	[addr    = 192.168.1.10]{custom-style="Verbatim Char"}\
  \	[status:]{custom-style="Verbatim Char"}\
  \	\	[nodeid:\	1:\	]{custom-style="Verbatim Char"}[localhost]{custom-style="red-bold"}\
  \	\	[nodeid:\	2:\	]{custom-style="Verbatim Char"}[connected]{custom-style="red-bold"}\
  [LINK ID 1 udp]{custom-style="Verbatim Char"}\
  \	[addr    = 192.168.3.10]{custom-style="Verbatim Char"}\
  \	[status:]{custom-style="Verbatim Char"}\
  \	\	[nodeid:\	1:\	]{custom-style="Verbatim Char"}[localhost]{custom-style="red-bold"}\
  \	\	[nodeid:\	2:\	]{custom-style="Verbatim Char"}[connected]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### PG-REXの停止

PG-REXを停止するには、Standbyを停止させ、Standbyの停止完了後にPrimaryを停止させます。

Primaryから停止した場合、フェイルオーバが発生しますので、ご注意ください。

PrimaryおよびStandbyの停止手順については、以降の項を参照してください。

この手順でPG-REXを停止させた場合、次にPG-REXを起動するときには、Primaryからのベースバックアップの取得は必要ありません。

::: {custom-style="First Paragraph"}
　
:::

### Standbyの停止

本節では、Standbyの停止手順を説明します。

本作業は停止対象のノードにて、rootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) Standbyを停止します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs cluster stop]{custom-style="Verbatim Char"}\
  [Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [Stopping Cluster (corosync)...]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(2) StandbyのPacemakerが正常に停止されたことを確認します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [Error: error running crm_mon, is pacemaker running?]{custom-style="red-bold"}\
  [\ \ error:\ Could\ not\ connect\ to\ launcher:\ Connection refused]{custom-style="red-bold"}\
  [\ \ crm_mon: Error: cluster is not available on this node]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) StandbyのPostgreSQLが正常に停止されたことを確認します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# ps \-ef | grep postgres]{custom-style="Verbatim Char"}\
  [root\ \ \ \ \ \ 3252 17408\ \ 0 17:18 pts/0\ \ \ \ 00:00:00 grep postgres]{custom-style="Verbatim Char"}\
  \
  [※ PostgreSQLのプロセスが存在しないことを確認します。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### Primaryの停止

本節では、Primaryの停止手順を説明します。

Standby稼働中にPrimaryを停止した場合、フェイルオーバが発生することに注意してください。

本作業は停止対象のノードにて、rootユーザで行います。

(1) Primaryを停止します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs cluster stop \-\-force]{custom-style="Verbatim Char"}\
  [Stopping Cluster (pacemaker)...]{custom-style="Verbatim Char"}\
  [Stopping Cluster (corosync)...]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) PrimaryのPacemakerが正常に停止されたことを確認します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [Error: error running crm_mon, is pacemaker running?]{custom-style="red-bold"}\
  [\ \ error:\ Could\ not\ connect\ to\ launcher:\ Connection refused]{custom-style="red-bold"}\
  [\ \ crm_mon: Error: cluster is not available on this node]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(3) PrimaryのPostgreSQLが正常に停止されたことを確認します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# ps \-ef | grep postgres]{custom-style="Verbatim Char"}\
  [root\ \ \ \ \ 20518 24450\ \ 0 17:28 pts/0\ \ \ \ 00:00:00 grep postgres]{custom-style="Verbatim Char"}\
  \
  [※ PostgreSQLのプロセスが存在しないことを確認します。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

