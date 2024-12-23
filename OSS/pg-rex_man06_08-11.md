リソース故障(demoteおよびstop)
-------------------------

この節では、リソース故障(demoteおよびstop)時の対処について説明します。  
ディスク故障の場合も同様のHAクラスタ状態となりますので、この節の手順で対処します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

リソース故障(demoteおよびstop)を検知し、pgrex02からpgrex01へのreset処理を実施しています。
reset処理の実行状況により、HAクラスタおよびデータベースサービスの状態は以下のようになります。

(1) reset処理が成功した場合
    
    フェイルオーバが発生し、pgrex02のPostgreSQLリソース(pgsql)がPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

    データベースサービスは片方のノード(pgrex02)で継続しています。

(2) reset処理が失敗した場合

    pgrex01の状態は不定となり、pgrex02はStandbyのままで、pgrex01に対してreset処理を繰り返しています。

    データベースサービスの稼働状況は不定です。

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

【STEP1：強制電源断 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

この作業は、pgrex01のノードの状態がOFFLINEとなって**いない**場合に実施します。

pgrex01の電源ボタンを押下し、電源を停止します。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

【STEP2：ノード状態・リソース状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認し、【STEP4】へ進みます。
pgrex01のノード状態がOFFLINEとなっていない場合は、【STEP3】へ進みます。

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ OFFLINE]{custom-style="red-bold"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\	Promoted\ pgrex02]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	Stopped]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP3：保守者介在処理 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

手動でpgrex01を停止させたことをHAクラスタに通知するために、stonith\_adminコマンドによる保守者介在処理を行います。

pgrex02で\"pacemaker-controld.\*notice:.\*was not terminated.\*\"をキーワードとし、/var/log/messagesに以下のログが出力されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [日時表示]{custom-style="italic"}[\ pgrex02\ pacemaker\-controld\[1531920\]:\ notice:\ ]{custom-style="Verbatim Char"}[Peer\ pgrex01\ was\ not\ terminated\ (reboot)]{custom-style="red-bold"}[\ by\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="italic"}[\ on\ behalf\ of\ pacemaker\-controld\.1531920:\ ]{custom-style="Verbatim Char"}[エラー内容]{custom-style="italic"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

pgrex02でstonith\_adminコマンドを以下のとおり実施します。

実施後、再度ノード状態を確認するため、【STEP2】へ戻ります。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# stonith_admin \-C\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="italic"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex02でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex01でPacemaker停止中)

-   故障箇所(pgrex01のリソース故障(demoteおよびstop)が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP6：ノード起動 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

この作業は、【STEP1】で、電源を停止した場合のみ実施します。

pgrex01の電源ボタンを押下し、ノードを起動します。

::: {custom-style="First Paragraph"}
　
:::

【STEP7：Pacemaker起動 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを起動します。起動する手順は『[@sec:Standbyの起動](#sec:Standbyの起動) [Standbyの起動](#sec:Standbyの起動)』を参照してください。

※ pgrex02でPostgreSQLリソースがPrimaryとして稼働中のため、pgrex01をStandbyとして起動します。

::: {custom-style="page-break"}
　
:::

【STEP8：ノード状態・リソース状態確認 [pgrex01]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="red-bold"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	]{custom-style="Verbatim Char"}[Unpromoted\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	Promoted\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf:pacemaker:ping):\ \ ]{custom-style="Verbatim Char"}[Started\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf:pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ storage-mon-clone\ [storage-mon]:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ storage-mon\	(ocf:heartbeat:storage-mon):]{custom-style="Verbatim Char"}[\	Started\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ storage-mon\	(ocf:heartbeat:storage-mon):\	Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ fence2\-ipmilan\	(stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	\	[Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::


リソース故障(ipaddr-primary)
------------------------

この節では、リソース故障(ipaddr-primary)時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

リソース故障(ipaddr-primary)を検知し、pgrex01でPostgreSQLリソース(pgsql)が停止された状態となっています。
その結果フェイルオーバが発生し、pgrex02のPostgreSQLリソースがPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは、片方のノード(pgrex02)で継続しています。

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
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	Promoted\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	Stopped]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):\	Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

【STEP2：Pacemaker停止 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

保守者の作業中に、PostgreSQLリソースが再起動しないようpgrex01のPacemakerを停止します。停止する手順は『[@sec:PostgreSQL停止中のノードの停止](#sec:PostgreSQL停止中のノードの停止) [PostgreSQL停止中のノードの停止](#sec:PostgreSQL停止中のノードの停止)』を参照してください。

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
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ OFFLINE]{custom-style="red-bold"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
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

-   故障箇所(IPaddr2(ipaddr-primary)故障が発生)

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

pgrex01のPacemakerを起動します。起動する手順は『[@sec:Standbyの起動](#sec:Standbyの起動) [Standbyの起動](#sec:Standbyの起動)』を参照してください。

※ pgrex02でPostgreSQLリソースがPrimaryとして稼働中のため、pgrex01のPostgreSQLリソースをStandbyとして起動します。

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
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="red-bold"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	]{custom-style="Verbatim Char"}[Unpromoted\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):\	Promoted\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ Clone\ Set:\ ping\-clone\ \[ping\]:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf:pacemaker:ping):\ \ ]{custom-style="Verbatim Char"}[Started\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ ping]{custom-style="Verbatim Char"}\	[\ \ (ocf:pacemaker:ping):\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ storage-mon-clone\ [storage-mon]:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ storage-mon\	(ocf:heartbeat:storage-mon):]{custom-style="Verbatim Char"}[\	Started\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ storage-mon\	(ocf:heartbeat:storage-mon):\	Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ fence2\-ipmilan\	(stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	\	[Started\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

リソース故障(ipaddr-replication)
---------------------

この節では、リソース故障(ipaddr-replication)時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

リソース故障(ipaddr-replication)を検知し、pgrex01のIPaddr2リソース(ipaddr-replication)が再起動した状態となっています。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは両ノードで継続しています。

::: {custom-style="page-break"}
　
:::

### 復旧

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
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\	Promoted\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\	Unpromoted\ pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node pgrex01\ (1):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ (故障回数表示)]{custom-style="red-bold"}\
  \
  [Failed Resource Actions:]{custom-style="red-bold"}\
  [\ \ \*\ (ipaddr\-replication制御エラー情報表示)]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP2：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex01でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(両ノードでPacemaker起動中)

-   故障箇所(IPaddr2(ipaddr-replication)故障が発生)

::: {custom-style="page-break"}
　
:::

【STEP3：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

復旧の必要がある場合、保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP4：リソース(ipaddr-replication)のフェイルカウントクリア \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のipaddr-replicationリソースのフェイルカウントをクリアします。
 
::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs resource cleanup ipaddr\-replication node=pgrex01]{custom-style="Verbatim Char"}\
  [Cleaned up ipaddr\-primary on pgrex01]{custom-style="Verbatim Char"}\
  [Cleaned up ipaddr\-replication on pgrex01]{custom-style="Verbatim Char"}\
  [Waiting for 1 reply from the controller.]{custom-style="Verbatim Char"}\
  [... got reply (done)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP5：ノード状態・リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。
 
::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex02]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \ (表示無し)]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

リソース故障(ipaddr-standby)
-----------------------

この節では、リソース故障(ipaddr-standby)時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

リソース故障(ipaddr-standby)を検出し、pgrex02のIPaddr2リソース(ipaddr-standby)がpgrex01へ移動した状態となっています。

::: {custom-style="First Paragraph"}
　
:::

データベースサービスは両ノードで継続しています。

::: {custom-style="page-break"}
　
:::

### 復旧

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
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\	Promoted\ pgrex01]{custom-style="red-bold"}\
  [\ \ \ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf:linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\	Unpromoted\ pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node pgrex02\ (2):]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ (故障回数表示)]{custom-style="red-bold"}\
  \
  [Failed Resource Actions:]{custom-style="red-bold"}\
  [\ \ \*\ (ipaddr\-standby制御エラー情報表示)]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP2：保守者へ報告】

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex01でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(両ノードでPacemaker起動中)

-   故障箇所(IPaddr2(ipaddr-standby)故障が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP3：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="page-break"}
　
:::

【STEP4：リソース(ipaddr-standby)の切り替え \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex02のipaddr-standbyリソースのフェイルカウントをクリアします。クリアすると自動的に切り替えが行なわれます。
 
::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs resource cleanup ipaddr\-standby node=pgrex02]{custom-style="Verbatim Char"}\
  [Cleaned up ipaddr\-standby on pgrex02]{custom-style="Verbatim Char"}\
  [Waiting for 1 reply from the controller. OK]{custom-style="Verbatim Char"}\
  [... got reply (done)]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP5：ノード状態・リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日時表示]{custom-style="italic"}[\ on\ pgrex01]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex01\ (1):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [\ \ \*\ Node\ pgrex02\ (2):\ online,\ feature\ set\ 3.19.0]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-primary\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \ \ \*\ ipaddr\-replication\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ pgrex01]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-standby\	\	(ocf:heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [Migration Summary:]{custom-style="Verbatim Char"}\
  [\ \ (表示無し)]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

