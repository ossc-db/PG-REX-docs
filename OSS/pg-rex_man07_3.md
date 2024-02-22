計画的なノード切り替え
------------------

本節では、手動による計画的なノード切り替えを実施する手順を記述します。

本節の作業は、rootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

### ノード切り替え

手動によるノード切り替えの手順を以下に示します。ノード切り替えの手順はフェイルオーバとリソースの再組み込みの手順で構成されています。

::: {custom-style="First Paragraph"}
　
:::

(1) フェイルオーバ実行

    pgrex01のPacemakerを停止し、Primaryをpgrex02に切り替えます。

::: {custom-style="First Paragraph"}
　
:::

(2) フェイルオーバ確認

    pgrex02でpcs statusコマンドを実行し、以下を確認します。

    -   ノード情報表示で、pgrex01がOFFLINEとなっていること。
    -   pgsql-cloneリソースが、pgrex02上でPrimaryとして動作していること。
    -   ipaddr-primaryリソース、ipaddr-standbyリソースが、pgrex02上で起動していること。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\[pgrex02\] # pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [\ \*\ Last change:\ \ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ by\ hacluster\ via\ crmd\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

(3) pgrex01の再組み込み準備

    pgrex01の再組み込みの準備をします。再組み込みの準備には、pgrex02からベースバックアップの取得、pg\_walの構成の修正、pgrex02のアーカイブログとの同期、起動禁止フラグの削除があります。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [\[pgrex01\] # su \- postgres]{custom-style="Verbatim Char"}\
  [最終ログイン: 2020/06/12 (金) 11:38:05 JST日時 pts/0]{custom-style="Verbatim Char"}\
  [\[pgrex01\] \$ rm \-rf \$PGDATA]{custom-style="Verbatim Char"}\
  [\[pgrex01\] \$ rm \-rf /dbfp/pgwal/pg_wal]{custom-style="Verbatim Char"}\
  [\[pgrex01\] \$ pg_basebackup \-h 192.168.2.3 \-U repuser \-D \$PGDATA \-X none \-P]{custom-style="Verbatim Char"}\
  [70762/70762 kB (100%), 1/1 テーブル空間]{custom-style="Verbatim Char"}\
  [NOTICE:  all required WAL segments have been archived]{custom-style="Verbatim Char"}\
  \
  [※ \-hにはレプリケーション受付用の仮想IPアドレス、]{custom-style="Verbatim Char"}\
  [\ \ \-Uにはレプリケーションユーザを指定]{custom-style="Verbatim Char"}\
  \
  [\[pgrex01\] \$ rsync \-av \-\-size\-only 192.168.2.3:/dbfp/pgarch/arc1/ /dbfp/pgarch/arc1/]{custom-style="Verbatim Char"}\
  [postgres@192.168.2.3's password:]{custom-style="Verbatim Char"}\
  [receiving incremental file list]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [sent 1,434 bytes  received 889,422,925 bytes  61,339,610.97 bytes/sec]{custom-style="Verbatim Char"}\
  [total size is 889,200,754  speedup is 1.00]{custom-style="Verbatim Char"}\
  \
  [※ 接続先はレプリケーション受付用の仮想IPアドレス]{custom-style="Verbatim Char"}\
  \
  [\[pgrex01\] \$ exit]{custom-style="Verbatim Char"}\
  [ログアウト]{custom-style="Verbatim Char"}\
  \
  [\[pgrex01\] # rm /var/lib/pgsql/tmp/PGSQL.lock]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(4) pgrex01の再組み込み

    pgrex01をStandbyとして起動します。

::: {custom-style="page-break"}
　
:::

(5) ノード切り替え確認

    pgrex01でpcs statusコマンドを実行し、以下を確認します。

    -   ノード情報表示で、pgrex01がOnlineとなっていること。
    -   pgsql-cloneリソースが、pgrex01上でStandbyとして動作していること。
    -   ipaddr-replicationリソースが、pgrex01上で起動していること。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [\[pgrex01\] # pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [\ \*\ Last change:\ \ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ by\ hacluster\ via\ crmd\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ ]{custom-style="Verbatim Char"}[pgrex01\ (1)]{custom-style="red-bold"}[\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Slave\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Master\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
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
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

