ルータ故障
----------

この節では、ルータ故障時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

S-LANのルータ故障を検知し、両ノードのPostgreSQLリソース(pgsql)、IPaddr2リソース(ipaddr-primary、ipaddr-standby、ipaddr-replication)が停止した状態となっています。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは停止しています。

::: {custom-style="First Paragraph"}
　
:::

### 復旧

pgrex01とpgrex02でPacemakerを停止し、保守者による復旧を依頼します。

保守者による故障復旧後、pgrex01とpgrex02のPacemakerを再起動し、復旧します。

復旧後のHAクラスタ状態は、pgrex02が先に停止した場合はpgrex01(Primary)-pgrex02(Standby)、pgrex01が先に停止した場合はpgrex01(Standby)-pgrex02(Primary)となります。

::: {custom-style="First Paragraph"}
　
:::

復旧手順を以下に説明します。

::: {custom-style="First Paragraph"}
　
:::

【STEP1：リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

pcs statusの結果を確認し、データが進んでいるノードを特定します。

pgsql-data-statusがLATESTとなっている場合、そのノードのデータが進んでいることを示しています。

以降、pgrex01が「データが進んでいるノード」の場合の復旧手順を示します。pgrex02が「データが進んでいるノード」の場合はpgrex01とpgrex02を読み替えて下さい。

::: {custom-style="First Paragraph"}
　
:::

【STEP2：Pacemaker停止 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

保守者の作業中に、PostgreSQLリソースが再起動しないようpgrex02のPacemakerを停止します。停止する手順は『PostgreSQL停止中のノードの停止』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP3：Pacemaker停止 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

保守者の作業中に、PostgreSQLリソースが再起動しないようpgrex01のPacemakerを停止します。停止する手順は『PostgreSQL停止中のノードの停止』を参照してください。

::: {custom-style="page-break"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(データベースサービス停止中)

-   報告時点でのHAクラスタ状態(2つのノードでPacemaker停止中)

-   故障箇所(ルータ故障が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP6：Pacemaker起動 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを起動します。起動する手順は『Primaryの起動』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP7：ノード状態・リソース状態確認 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\]]{custom-style="red-bold"}\
  [\ \*\ OFFLINE:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Stopped]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):]{custom-style="Verbatim Char"}[\ \ Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【STEP8：Pacemaker起動 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

pgrex02のPacemakerを起動します。起動する手順は『Standbyの起動』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP9：ノード状態・リソース状態確認 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)]{custom-style="Verbatim Char"}[\ pgrex02\ (2)]{custom-style="red-bold"}[\ \]]{custom-style="Verbatim Char"}\
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
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

S-LAN故障
---------

この節では、S-LAN故障時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

S-LAN故障を検知し、pgrex01でPostgreSQLリソース(pgsql)が停止した状態となっています。

その結果フェイルオーバが発生し、pgrex02のPostgreSQLリソースがPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは片方のノード(pgrex02)で継続しています。

::: {custom-style="First Paragraph"}
　
:::

### 復旧

データベースサービス状況の確認とpgrex01のPacemakerを停止し、保守者による復旧を依頼します。

保守者による故障復旧後、pgrex01のPacemakerを再起動します。

復旧後のHAクラスタ状態は、pgrex01(Standby) - pgrex02(Primary)となります。

::: {custom-style="First Paragraph"}
　
:::

復旧手順を以下に説明します。

::: {custom-style="First Paragraph"}
　
:::

【STEP1：リソース状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

リソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

【STEP2：Pacemaker停止 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

保守者の作業中に、PostgreSQLリソースが再起動しないようpgrex01のPacemakerを停止します。停止する手順は『PostgreSQL停止中のノードの停止』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP3：ノード状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------


::: {custom-style="First Paragraph"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex02でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex01でPacemaker停止中)

-   故障箇所(S-LAN故障が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP6：Pacemaker起動 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを起動します。

pgrex02でPostgreSQLリソースがPrimaryとして稼働中のため、pgrex01をStandbyとして起動します。

起動する手順は『Standbyの起動』を参照してください。

::: {custom-style="page-break"}
　
:::

【STEP7：ノード状態・リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ ]{custom-style="Verbatim Char"}[pgrex01\ (1)]{custom-style="red-bold"}[\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Slave\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

D-LAN故障
---------

この節では、D-LAN故障時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

D-LAN故障を検知し、pgrex02を切り離した状態となっています。

その結果、pgrex02のIPaddr2リソース(ipaddr-standby)がpgrex01へ移動します。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは片方のノード(pgrex01)で継続しています。

::: {custom-style="First Paragraph"}
　
:::

### 復旧

データベースサービス状況の確認とpgrex02のPacemakerを停止し、保守者による復旧を依頼します。

保守者による故障復旧後、pgrex02のPacemakerを再起動し、復旧します。

::: {custom-style="First Paragraph"}
　
:::

復旧手順を以下に説明します。

::: {custom-style="First Paragraph"}
　
:::

【STEP1：リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

リソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Master\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Slave\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【STEP2：Pacemaker停止 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex02のPacemakerを停止します。停止する手順は『Standbyの停止』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP3：ノード状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \ 
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex02\ (2)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex01でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex02でPacemaker停止中)

-   故障箇所(D-LAN故障が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP6：Pacemaker起動 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

pgrex02のPacemakerを起動します。起動する手順は『Standbyの起動』を参照してください。

::: {custom-style="page-break"}
　
:::

【STEP7：ノード状態・リソース状態確認 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)]{custom-style="Verbatim Char"}[\ pgrex02\ (2)]{custom-style="red-bold"}[\ \]]{custom-style="Verbatim Char"}\
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
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

リソース故障(monitor)
---------------------

この節では、リソース故障(monitor)時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

リソース故障(monitor)を検知し、pgrex01でPostgreSQLリソース(pgsql)が停止した状態となっています。

その結果フェイルオーバが発生し、pgrex02のPostgreSQLリソースがPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは片方のノード(pgrex02)で継続しています。

::: {custom-style="First Paragraph"}
　
:::

### 復旧

データベースサービス状況の確認とpgrex01のPacemakerを停止し、保守者による復旧を依頼します。

保守者による故障復旧後、pgrex01のPacemakerを再起動し、復旧します。

復旧後のHAクラスタ状態は、pgrex01(Standby) - pgrex02(Primary)となります。

::: {custom-style="First Paragraph"}
　
:::

復旧手順を以下に説明します。

::: {custom-style="First Paragraph"}
　
:::

【STEP1：リソース状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

リソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Master\ pgrex02]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【STEP2：Pacemaker停止 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを停止します。停止する手順は『PostgreSQL停止中のノードの停止』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP3：ノード状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex02でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex01でPacemaker停止中)

-   故障箇所(pgrex01のリソース故障(monitor)が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP6：Pacemaker起動 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを起動します。

pgrex02でPostgreSQLリソースがPrimaryとして稼働中のため、pgrex01をStandbyとして起動します。

起動する手順は『Standbyの起動』を参照してください。

::: {custom-style="page-break"}
　
:::

【STEP7：ノード状態・リソース状態確認 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ ]{custom-style="Verbatim Char"}[pgrex01\ (1)]{custom-style="red-bold"}[\ pgrex02\ (2)\ \]]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Slave\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ ]{custom-style="Verbatim Char"}[Slave\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):\ Master\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf::pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

