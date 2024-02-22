故障対応
========

本章では、HAクラスタに故障が発生した場合の監視者が行う作業について説明します。

監視者による作業にはHAクラスタ状態確認と復旧があります。

-   HAクラスタ状態確認では、HAクラスタに発生した故障箇所を特定し、保守者への報告と修復作業の依頼を実施します。
-   復旧では、データベースサービス継続に必要となる処置及び、保守者の修復作業終了後にHAクラスタを故障発生前の状態に戻す作業を実施します。

保守者は、監視者からの修復作業依頼により、故障したアプリケーションの詳細解析、原因調査、修復作業を実施します。故障の種類によっては、復旧の際に保守者に作業を委ねている箇所があります(保守者介在処理と呼びます)。

なお、本作業にはスーパーユーザ権限が必要となります。

STONITHが発生した場合は、復旧手順の最後に以下のコマンドで両ノードに対してSTONITH履歴のクリアを実施してください。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# stonith_admin -c -H \<ノード名\>]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------
  
前提条件
--------

この章の前提条件を以下に示します。

-   両ノードが稼働している状態でpgrex01の故障が起きたと仮定しています。一般的に多重故障はPG-REXの適用範囲外となりますが、STONITHの失敗については対応しており本章の説明にも含まれています。

::: {custom-style="page-break"}
　
:::

監視コマンド表示確認方法
------------------------

HAクラスタに発生した故障を特定するために、pcs status \-\-fullコマンド実行時に表示されるノード情報、リソース情報、属性情報、故障回数、制御エラー情報、及びcorosync-cfgtool -sコマンド実行時に表示されるIC-LANの通信状態を確認する必要があります。

::: {custom-style="First Paragraph"}
　
:::

以下にpcs statusコマンドの実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

なお、pcs status \-\-fullコマンドを実行し、[\"Error: error running crm_mon, is pacemaker running? Error: cluster is not available on this node\"]{custom-style="Verbatim Char"}と表示された場合、pcs status \-\-fullコマンドを実行したノードのPacemakerは停止しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [Cluster\ name:\ ]{custom-style="Verbatim Char"}[HAクラスタ名]{custom-style="italic"}\
  [Cluster Summary:]{custom-style="Verbatim Char"}\
  [\ \*\ Stack:\ corosync]{custom-style="Verbatim Char"}\
  [\ \*\ Current\ DC:\ pgrex01\ (1)\ ]{custom-style="Verbatim Char"}[バージョン]{custom-style="italic"}[\ \-\ partition\ with\ quorum]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  \
  [Full\ list\ of\ resources:]{custom-style="Verbatim Char"}\
  \
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Slave\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  \
  [Node\ Attributes:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1000]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ LATEST]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-master\-baseline]{custom-style="Verbatim Char"}\	\	\	[:\ 0000000005000060]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ PRI]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex02\ (2):]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 100]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ STREAMING|SYNC]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ HS:sync]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="Verbatim Char"}\
  \
  [Migration\ Summary:]{custom-style="Verbatim Char"}\
  \
  [PCSD\ Status:]{custom-style="Verbatim Char"}\
  [\ \ pgrex01:\ Online]{custom-style="Verbatim Char"}\
  [\ \ pgrex02:\ Online]{custom-style="Verbatim Char"}\
  \
  [Daemon\ Status:]{custom-style="Verbatim Char"}\
  [\ \ corosync:\ active/disabled]{custom-style="Verbatim Char"}\
  [\ \ pacemaker:\ active/disabled]{custom-style="Verbatim Char"}\
  [\ \ pcsd:\ active/enabled]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------


::: {custom-style="page-break"}
　
:::

以下にcorosync-cfgtoolコマンドの実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# corosync\-cfgtool \-s]{custom-style="Verbatim Char"}\
  [Printing link status.]{custom-style="Verbatim Char"}\
  [Local node ID 1]{custom-style="Verbatim Char"}\
  [LINK ID 0]{custom-style="Verbatim Char"}\
  [addr = 192.168.1.1]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1: localhost]{custom-style="Verbatim Char"}\
  \	[nodeid  2: connected]{custom-style="Verbatim Char"}\
  [LINK ID 1]{custom-style="Verbatim Char"}\
  [addr = 192.168.3.1]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1: localhost]{custom-style="Verbatim Char"}\
  \	[nodeid  2: connected]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### 表示部説明

pcs statusコマンド実行時の各表示部について説明します。

::: {custom-style="First Paragraph"}
　
:::

【ノード情報表示部】

  ------------------------------------------------------------------------
  [\ \*\ Online:\ \[\ pgrex01\ (1)\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

各ノードの名前やPacemakerの稼働状態が表示されます。稼働状態にはOnline、OFFLINE、UNCLEAN(online)、UNCLEAN(offline)が存在します。

また、Pacemaker稼働時は、HAクラスタを構成しているノードが\"\[\]\"内に表示されます。

ノード名の横に括弧で表示されている数字はノードIDを表します。

::: {custom-style="First Paragraph"}
　
:::

【リソース情報表示部】

  ------------------------------------------------------------------------
  [Full\ list\ of\ resources:]{custom-style="Verbatim Char"}\
  \
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Slave\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	\ [\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

リソースID、リソースの稼働状態や稼働ノードの名前が表示されます。

各リソースが示す稼働状況を、以下に示します。

::: {custom-style="First Paragraph"}
　
:::

■ pgsql-clone(PG-REXリソース)

::: {custom-style="Table Caption"}
PG-REXリソースの稼働状況表示一覧
:::

  --------------------------------------------------------------
  pcs status実行結果の表示      稼働状況の説明
  ----------------------------- --------------------------------
  Master pgrex01\               両ノードでリソースが稼働中
  Slave pgrex02

  Master pgrex01\               片方のノード(pgrex01)でリソースが稼働中
  Stopped

  Stopped\                      両ノードでリソースが停止中
  Stopped
  --------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

■ ipaddr-primary, ipaddr-replication, ipaddr-standby(IPaddr2リソース), fence1-ipmilan, fence2-ipmilan(STONITHリソース)

::: {custom-style="Table Caption"}
IPaddr2リソースおよびSTONITHリソースの稼働状況表示一覧
:::

  ---------------------------------------------------
  pcs status実行結果の表示 稼働状況の説明
  ------------------------ --------------------------
  Started pgrex01          pgrex01でリソースが稼働中

  Stopped                  リソースが停止中
  ---------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

■ ping-clone(PINGリソース)

::: {custom-style="Table Caption"}
PINGリソースの稼働状況表示一覧
:::

  --------------------------------------------------------------
  pcs status実行結果の表示      稼働状況の説明
  ----------------------------- --------------------------------
  Started pgrex01\               両ノードでリソースが稼働中
  Started pgrex02

  Started pgrex01\               片方のノード(pgrex01)でリソースが稼働中
  Stopped

  Stopped\                      両ノードでリソースが停止中
  Stopped
  --------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【属性情報表示部】

  ------------------------------------------------------------------------
  [Node\ Attributes:]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex01\ (1):]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1000]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ LATEST]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-master\-baseline]{custom-style="Verbatim Char"}\	\	\	[:\ 0000000005000060]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ PRI]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="Verbatim Char"}\
  [\ \*\ Node\ pgrex02\ (2):]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[:\ 100]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ STREAMING\|SYNC]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ HS\|SYNC]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ 1]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

各ノードにおけるネットワーク経路の監視状態、およびPG-REXリソース状態を表示します。

pgrex01の各監視先の属性の正常値の例を以下に示します。

::: {custom-style="page-break"}
　
:::

::: {custom-style="Table Caption"}
監視先の属性の正常値
:::

  -----------------------------------------------------------------------------------
  属性                      正常値                  説明
  ------------------------- ----------------------  ---------------------------------
  master-pgsql              1000(pgrex01),\         PG-REXリソースの属性で、\
                            100(pgrex02)            PacemakerがPrimaryおよびStandby\
                                                    のリソースの状態を管理する

  pgsql-data-status         LATEST(pgrex01),\       PG-REXリソースの属性で、\
                            STREAMING|SYNC(pgrex02) PostgreSQLのデータの状態を示す

  pgsql-master-baseline     LSN(pgrex01),\          PG-REXリソースの属性で、\
                            表示なし(pgrex02)       PostgreSQLがpromote(Primaryに\
                                                    なる)直前のLSNの値を示す

  pgsql-status              PRI(pgrex01),\          PG-REXリソースの属性で、\
                            HS:sync(pgrex02)        PostgreSQLの現在の遷移状態を\
                                                    示す

  pgsql-xlog-loc            正常時は属性そのもの\   PG-REXリソースの属性で、\
                            が表示されない          起動時にPrimaryが存在しない場合\
                                                    に、Primaryになれるかどうかを\
                                                    決定するために設定される

  ping-status               1                       ネットワーク経路の状況を示す

  -----------------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【故障回数表示部】

  ------------------------------------------------------------------------
  [Migration Summary:]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

ノード毎に故障したリソースIDと故障許容回数(migration-threshold)、故障した回数が表示されます。

以下に故障回数表示部の出力フォーマットを示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \*\ Node pgrex01:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ]{custom-style="Verbatim Char"}[pgsql]{custom-style="underline"}[:\ ]{custom-style="Verbatim Char"}[migration\-threshold=1]{custom-style="underline"}\ [fail\-count=1]{custom-style="underline"}[\ last\-failure=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\']{custom-style="Verbatim Char"}\
  [\ \ \ \ (1)\ \ \ \ \ \ \ \ \ \ \ (2)\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (3)]{custom-style="Verbatim Char"}\
  \
  [(1) 故障リソースID (2) 故障許容回数 (3) 故障回数]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【制御エラー情報表示部(※ リソース故障時のみ表示)】

  ------------------------------------------------------------------------
  [Failed Resource Actions:]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

制御エラー情報表示部は制御エラーが発生した場合のみ表示されます。

制御エラーが発生したリソースIDと検知オペレーション(start/stop/monitor/promote/demote)、故障発生ノード、リターンコード、エラー内容(\"error\"、\"TimedOut\"等)が表示されます。

以下に制御エラー情報表示部の出力フォーマットを示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ ]{custom-style="Verbatim Char"}[pgsql\_monitor]{custom-style="underline"}[\_9000\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="underline"} [\'not running\']{custom-style="underline"} [(7)]{custom-style="underline"}[: call=79, status=complete,]{custom-style="Verbatim Char"}\
  [\ \ \ (1)\ \ \ \ (2)\ \ \ \ \ \ \ \ \ \ \ \ \ (3)\ \ \ \ \ \ \ \ (4)\ \ \ \ \ (5)]{custom-style="Verbatim Char"}\
  [exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=0ms, exec=0ms]{custom-style="Verbatim Char"}\
  \
  [(1) 故障リソースID  (2) 検知オペレーション  (3) 故障発生ノード名]{custom-style="Verbatim Char"}\
  [(4) エラー内容  (5) リターンコード]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【Fencing History情報表示部(※履歴がある場合のみ表示)】

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Fencing History:]{custom-style="Verbatim Char"}\
  [\ \*\ reboot of\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="underline"}[\ successful: delegate=]{custom-style="Verbatim Char"}[pgrex01]{custom-style="underline"}[,]{custom-style="Verbatim Char"}\
  [\ \ \ \ \ \ \ \ \ \ \ \ \ \ (1)\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (2)]{custom-style="Verbatim Char"}\
  [client=pacemaker-controld.21654, origin=pgrex01,]{custom-style="Verbatim Char"}\
  [ completed=']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\']{custom-style="Verbatim Char"}\
  \
  [(1) STONITH対象ノード  (2) STONITH実行ノード]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

corosync-cfgtool -sコマンド実行時の表示部について説明します。

::: {custom-style="First Paragraph"}
　
:::

このコマンドでは、IC-LANのIPアドレス毎にPrimaryノードおよびStandbyノードの通信状態が表示されます。

::: {custom-style="First Paragraph"}
　
:::

以下に出力フォーマットを示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# corosync\-cfgtool \-s]{custom-style="Verbatim Char"}\
  [Printing link status.]{custom-style="Verbatim Char"}\
  [Local node ID 1]{custom-style="Verbatim Char"}\
  [LINK ID 0]{custom-style="Verbatim Char"}\
  [addr = 192.168.1.1]{custom-style="underline"}\
  [(1)]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1: localhost]{custom-style="underline"}\
  \	\	[(2)]{custom-style="Verbatim Char"}\
  \	[nodeid  2: connected]{custom-style="underline"}\
  \	\	[(3)]{custom-style="Verbatim Char"}\
  [LINK ID 1]{custom-style="Verbatim Char"}\
  [addr = 192.168.3.1]{custom-style="underline"}\
  [(4)]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1: localhost]{custom-style="underline"}\
  \	\	[(2)]{custom-style="Verbatim Char"}\
  \	[nodeid  2: connected]{custom-style="underline"}\
  \	\	[(3)]{custom-style="Verbatim Char"}\
  [(1) IC-LAN(eno1)のIPアドレス]{custom-style="Verbatim Char"}\
  [(2) ノードID[^47]が1のノードとのIC-LANの通信状態]{custom-style="Verbatim Char"}\
  [(3) ノードID[^47]が2のノードとのIC-LANの通信状態]{custom-style="Verbatim Char"}\
  [(4) IC-LAN(eno3)のIPアドレス ]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

IC-LANの通信状態を、以下に示します。

::: {custom-style="Table Caption"}
IC-LANの通信状態
:::

  -------------------------------------------------
  corosync-cfgtool実行結果の表示    通信状態の説明
  -------------------------------------------------
  connected                        接続状態

  disconnected                     未接続状態
  -------------------------------------------------

::: {custom-style="page-break"}
　
:::

### 正常状態確認方法

pcs status \-\-fullコマンド実行及びcorosync\-cfgtool \-sコマンド実行結果の全ての表示部において正常状態の確認ができた場合、HAクラスタは正常状態です。

::: {custom-style="First Paragraph"}
　
:::

● pcs status \-\-fullコマンド確認項目

::: {custom-style="First Paragraph"}
　
:::

【ノード情報表示部】

pgrex01とpgrex02のノード状態が\"Online\"状態になっていることを確認する

::: {custom-style="First Paragraph"}
　
:::

【『リソース情報表示部』の『PG-REXリソース、IPaddr2リソース』】

それぞれのノードで、PG-REXリソース(pgsql-clone)、IPaddr2リソース(ipaddr-primary、ipaddr-standby、ipaddr-replication)が、以下のとおりに稼働していることを確認する。

+ pgrex01側 ： pgsql-clone(Primary), ipaddr-primary, ipaddr-replication
+ pgrex02側 ： pgsql-clone(Standby), ipaddr-standby

::: {custom-style="First Paragraph"}
　
:::

【『リソース情報表示部』の『STONITHリソース』】

STONITHリソース(fence1-ipmilan、fence2-ipmilan)が、それぞれのノードで稼働していることを確認する。

::: {custom-style="First Paragraph"}
　
:::

【『リソース情報表示部』の『PINGリソース』】

ネットワーク経路監視用PINGリソース(ping-clone)が、それぞれのノードで稼働していることを確認する。

::: {custom-style="First Paragraph"}
　
:::

【属性情報表示部】

PG-REXリソース、ネットワーク経路の監視状態の各属性が正常値であることを確認する。

::: {custom-style="First Paragraph"}
　
:::

【制御エラー情報表示部】

制御エラー情報が表示されていないことを確認する。

::: {custom-style="First Paragraph"}
　
:::

【Fencing History情報表示部】

Fencing History情報が表示されていないことを確認する。

::: {custom-style="First Paragraph"}
　
:::

● corosync-cfgtool -sコマンド確認項目

::: {custom-style="First Paragraph"}
　
:::

corosync-cfgtool -sコマンドでは、出力が「localhost」、「connected」であることを確認します。

::: {custom-style="page-break"}
　
:::

故障箇所特定手順
----------------

本節では、HAクラスタに発生した故障を特定する手順について説明します。

故障箇所特定を以下の手順で行います。

1. ノード情報・リソース情報・故障回数表示部の確認

    pcs statusコマンドの実行結果から、ノードの起動状態の確認、D-LAN故障の特定、ハードウェア故障・リソース故障の切り分けを行います。

2. 属性情報表示部の確認

    ネットワーク経路故障のハードウェア故障を特定します。

3. corosync-cfgtool -sによるIC-LAN状態の確認

    IC-LAN故障を特定します。

4. 制御エラー情報表示部の確認

    故障リソース、故障ノード、故障オペレーションを特定します。

5. /var/log/messagesの確認

    Pacemaker停止ノードに発生した故障を特定します。


::: {custom-style="First Paragraph"}
　
:::

### ノード情報・リソース情報・故障回数表示部の確認

ノード情報・リソース情報・故障回数表示部の確認では、ノードの起動状態を確認し、その状態に応じた確認を行います。pgrex01、pgrex02それぞれでpcs status \-\-fullを実行し、以下の順に確認します。

1. ノードの起動状態の確認
2. D-LAN故障の特定
3. ハードウェア故障・リソース故障の特定

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

【ノードの起動状態の確認】

pgrex02のpcs status \-\-fullの実行結果のノード表示部が以下に該当する場合、『6.3.5. /var/log/messagesの確認』へ進みます。

::: {custom-style="First Paragraph"}
　
:::

  -----------------------------------------------------------------
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="Verbatim Char"}\
  \
  [※ pgrex01がOFFLINEになっている]{custom-style="Verbatim Char"}

  ---------------------------------

::: {custom-style="First Paragraph"}
　
:::

【D-LAN故障の特定】

pgrex01でpcs status \-\-fullコマンドを実行し、リソース情報、属性情報を確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Node pgrex02:]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	[: \-INFINITY]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	[:\ ]{custom-style="Verbatim Char"}[DISCONNECT]{custom-style="red-bold"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	[:\ ]{custom-style="Verbatim Char"}[HS:alone]{custom-style="red-bold"}\
  [\ \ \*\ ping\-status]{custom-style="Verbatim Char"}\	\	\	\	[: 1]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

属性情報表示部で、pgrex02のpgsql-data-statusがDISCONNECT、pgsql-statusがHS:aloneにそれぞれ変更されていることを確認します。

次に、pgrex01のPostgreSQLのサーバログファイル[^37] からwalsenderプロセスの停止を示すログ([terminating walsender]{custom-style="Verbatim Char"})を検索します。

該当のログが出力されていた場合、D-LAN故障と特定できます。

D-LAN故障と特定された場合は、『D-LAN故障』の節へ進みます。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# grep \'terminating walsender\' /var/log/pg_log/postgresql-2020-04-17.log]{custom-style="Verbatim Char"}\
  [2020\-04\-17\ 13:13:41\ JST\ 13673\ 5ea65b91\.3569\-2\ 0\ (repuser,\ \[unknown\],\ 192\.168\.2\.2(50338),\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[)\ LOG:\ \ ]{custom-style="Verbatim Char"}[terminating walsender process due to replication timeout]{custom-style="red-bold"}\
  \
  [※\ PostgreSQLのサーバログファイルのファイル名は適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【ハードウェア故障・リソース故障の特定】

pgrex02のpcs statusの実行結果の故障回数表示部から、故障回数(fail-count)の表示の有無によりハードウェア故障(ネットワーク等)またはリソース故障を判断します。

故障回数表示部に故障回数が表示されている場合、リソース故障と判断して『制御エラー情報表示部の確認』の項へ進みます。

故障回数が表示されていない場合、ハードウェア故障と判断して『属性情報表示部の確認』の項へ進みます。

::: {custom-style="First Paragraph"}
　
:::

### 属性情報表示部の確認

属性情報表示部の確認では、pgrex02でpcs statusコマンドを実行し、異常値を示している属性名を調べ、故障を特定します。

属性情報表示部の出力と対応する故障内容を以下の表に示します。故障が特定できた場合は、特定された故障内容の節へ進みます。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
属性情報別故障箇所対応表
:::

  --------------------------------------------------------------------------------------
  属性名                    属性値(pgrex01) 属性値(pgrex02) 故障発生ノードまたは故障箇所
  ------------------------- --------------- --------------- ----------------------------
  ping-status               0               1               S-LAN故障(pgrex01)

  同上                      1               0               S-LAN故障(pgrex02)

  同上                      0               0               ルータ故障(pgrex01, pgrex02)

  pgsql-data-status         LATEST          DISCONNECT      D-LAN故障

  pgsql-status              PRI             HS:alone        D-LAN故障

  --------------------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

以下にpcs statusコマンド実行時の表示例を示します。この例では、pgrex01のNode Attributesに表示されているping-statusの属性値が異常を示していることから、pgrex01にてS-LANの故障を検知したことを示しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [： (略)]{custom-style="Verbatim Char"}\
  [Node Attributes:]{custom-style="Verbatim Char"}\
  [\ \*\ Node pgrex01:]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	\	[: \-INFINITY]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	\	[: DISCONNECT]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	\	[: STOP]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="red-bold"}\	\	\	\	\	[: 0]{custom-style="red-bold"}\	[: Connectivity is lost]{custom-style="red-bold"}\
  [\ \*\ Node pgrex02:]{custom-style="Verbatim Char"}\
  [\ \ \*\ master\-pgsql]{custom-style="Verbatim Char"}\	\	\	\	\	[: 1000]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-data\-status]{custom-style="Verbatim Char"}\	\	\	\	[: LATEST]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-master\-baseline]{custom-style="Verbatim Char"}\	\	\	\	[: 00000139210029D8]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql\-status]{custom-style="Verbatim Char"}\	\	\	\	\	[: PRI]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping\-status]{custom-style="red-bold"}\	\	\	\	\	[: 1]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### corosync-cfgtool -sによるIC-LAN状態の確認

corosync-cfgtool -sによるIC-LAN状態の確認では、Pacemakerが起動しているノードでcorosync-cfgtoolコマンドを実行してIC-LAN通信状態を確認し、「/var/log/messagesの確認」の節へ進みます。

::: {custom-style="First Paragraph"}
　
:::

以下にIC-LAN故障発生時のcorosync-cfgtoolコマンド実行時の表示例を示します。この例では、nodeid 1がdisconnectedを示していることから、pgrex01にてIC-LANの故障を検知したことを示しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [： (略)]{custom-style="Verbatim Char"}\
  [LINK ID 0]{custom-style="Verbatim Char"}\
  [addr = 192.168.1.1]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1:\ ]{custom-style="Verbatim Char"}[disconnected]{custom-style="red-bold"}\
  \	[nodeid  2:\ ]{custom-style="Verbatim Char"}[localhost]{custom-style="Verbatim Char"}\
  [LINK ID 1]{custom-style="Verbatim Char"}\
  [addr = 192.168.3.1]{custom-style="Verbatim Char"}\
  [status:]{custom-style="Verbatim Char"}\
  \	[nodeid  1:\ ]{custom-style="Verbatim Char"}[disconnected]{custom-style="red-bold"}\
  \	[nodeid  2:\ ]{custom-style="Verbatim Char"}[localhost]{custom-style="Verbatim Char"}\

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### 制御エラー情報表示部の確認

制御エラー情報表示部の確認では、pgrex02でpcs statusコマンドを実行し、リソースに発生した故障を特定します。故障を特定できた場合は、特定された故障の節へ進みます。

::: {custom-style="First Paragraph"}
　
:::

【monitor故障の特定】

以下にmonitor故障発生時のpcs statusコマンド実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ pgsql_monitor]{custom-style="red-bold"}[\_9000\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'not running\' (7): call=79, status=complete, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【demote故障の特定】

以下にdemote故障発生時のpcs statusコマンド実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ pgsql_demote_0]{custom-style="red-bold"}[\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=88, status=Timed Out, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【stop故障の特定】

以下にstop故障発生時のpcs statusコマンド実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ pgsql_stop_0]{custom-style="red-bold"}[\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=87, status=Timed Out, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【ipaddr-primary故障の特定】

以下にipaddr-primary故障発生時のpcs statusコマンド実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-primary_monitor]{custom-style="red-bold"}[\_10000\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=22, status=complete, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【ipaddr-standby故障の特定】

以下にipaddr-standby故障発生時のpcs statusコマンド実行時の表示例を示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby_monitor]{custom-style="red-bold"}[\_10000\ on\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}[\ \'unknown error\' (1): call=16, status=complete, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【ipaddr-replication故障の特定】

以下にipaddr-replication故障発生時のpcs statusコマンド実行時の表示例を示します。

ipaddr-replicationの故障(monitor)の場合、リソースを再起動することで故障からの自動回復をする設定になっています。この時、故障回数表示部に故障回数だけが表示されます。

以下の例では、\"ipaddr-replication\"が1回故障したことを示しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [:（略）]{custom-style="Verbatim Char"}\
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \*\ Node pgrex01:]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication]{custom-style="red-bold"}[: migration\-threshold=0\ ]{custom-style="Verbatim Char"}[fail\-count=1]{custom-style="red-bold"}[\ last\-failure=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\']{custom-style="Verbatim Char"}\
  [\ \*\ Node pgrex02:]{custom-style="Verbatim Char"}\
  \
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr-replication_monitor]{custom-style="red-bold"}[\_10000\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=77, status=complete, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

以下の表示例のようにリソース故障(monitor)とリソース故障(stop)が発生している場合、特定される故障内容はリソース故障(stop)になります。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [：（略）]{custom-style="Verbatim Char"}\
  [Failed Resource Actions:]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-primary_monitor]{custom-style="red-bold"}[\_10000\ on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=22, status=complete, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}\
  [\ \*\ pgsql_stop]{custom-style="red-bold"}[\_0 on\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}[\ \'unknown error\' (1): call=87, status=Timed Out, exitreason=\'\', last\-rc\-change=\']{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\', queued=XXms, exec=XXms]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

### /var/log/messagesの確認

両方のノードでPacemakerが稼働している場合は両ノードのログファイル(/var/log/messages)から、Pacemakerが停止しているノードがある場合はPacemakerが停止しているノードのログファイルから、以下に示す2つのエラーメッセージを検索し、3種の故障を特定します。故障特定後は、特定された故障の節へ進みます。

::: {custom-style="First Paragraph"}
　
:::

【リソース故障(stop)の確認】

以下のコマンドを実行します。コマンドを実行した結果、エラーメッセージが出力された場合、PostgreSQLリソース(pgsql)のstop故障が発生したことを示しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [#\ grep\ \-e\ \'\.\*pacemaker\-controld\.\*notice:\.\*Result\ of\ stop\ operation\ for\.\*:\ error\.\*\'\ \-e\ \'\.\*pacemaker\-controld\.\*error:\.\*Result\ of\ stop\ operation\ for\.\*:\ Timed\ Out\.\*\'\ /var/log/messages]{custom-style="Verbatim Char"}\
  [Jan\ 20\ 15:22:47\ pgrex01\ <daemon\.err>\ pacemaker\-controld\[11207\]:\ ]{custom-style="Verbatim Char"}[error:\ Result\ of\ stop\ operation\ for\ pgsql]{custom-style="red-bold"}[\ on\ pgrex01:\ Timed\ Out]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【IC-LAN故障の確認】

以下のコマンドを実行します。コマンドを実行した結果、エラーメッセージが出力された場合、IC-LAN故障が発生したことを示しています。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [#\ grep\ \'\.\*pacemaker\-controld\.\*notice:\.\*is\ now\ lost\.\*\'\ /var/log/messages]{custom-style="Verbatim Char"}\
  [\　Jan\ \ 9\ 14:24:58\ pgrex01\ <daemon\.notice>\ pacemaker\-controld\[20520\]:\ notice:\ Node\ pgrex02\ state\ ]{custom-style="Verbatim Char"}[is\ now\ lost]{custom-style="red-bold"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【ノード故障の確認】

リソース故障(stop)およびIC-LAN故障の確認でエラーメッセージが検索されなかった場合、ノード故障 (Pacemaker故障またはOS故障) が発生したと判断します。

::: {custom-style="page-break"}
　
:::
