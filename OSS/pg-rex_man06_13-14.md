ノード故障
----------

この節では、ノード故障時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

OS故障、電源断、またはPacemakerのプロセス故障により、pgrex02がpgrex01の異常を検知し、pgrex01へreset処理を実施しています。
reset処理の実行状況により、HAクラスタおよびデータベースサービスの状態は以下のようになります。

(1) reset処理が成功した場合

    フェイルオーバが発生し、pgrex02のPostgreSQLリソース(pgsql)がPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

    データベースサービスは片方のノード(pgrex02)で継続しています。

(2) reset処理が失敗した場合

    pgrex02はStandby状態のままで、pgrex01に対してreset処理を繰り返しています。

    データベースサービス稼動状況は不定です。

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

::: {custom-style="page-break"}
　
:::

【STEP2：ノード状態・リソース状態確認 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認し、【STEP4】へ進みます。

pgrex01のノード状態がOFFLINEとなっていない場合は、【STEP3】へ進みます。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last updated:]{custom-style="Verbatim Char"} [日時表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex02\ (2)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex01\ (1)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable):]{custom-style="Verbatim Char"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started\ pgrex02]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}
  
  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP3：保守者介在処理 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

手動でpgrex01を停止させたことをHAクラスタに通知するために、stonith\_adminコマンド
による保守者介在処理を行います。

pgrex02で\"[pacemaker-controld.\*notice:.\*was not terminated.\*\"]{custom-style="Verbatim Char"}をキーワードとし、/var/log/messagesに以下のログが出力されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Jan\ 23\ 15:49:27\ pgrex02\ pacemaker\-controld\[1531920\]:\ notice:\ ]{custom-style="Verbatim Char"}[Peer\ pgrex01\ was\ not\ terminated\ (reboot)]{custom-style="red-bold"}[\ by\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="italic"}[\ on\ behalf\ of\ pacemaker\-controld\.1531920:\ ]{custom-style="Verbatim Char"}[エラー内容]{custom-style="italic"}

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

::: {custom-style="page-break"}
　
:::

【STEP4：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex02でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex01でPacemaker停止中)

-   故障箇所(pgrex01のノードまたはPacemaker故障が発生)

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

【STEP7：Pacemaker起動 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

pgrex01のPacemakerを起動します。起動する手順は『Standbyの起動』を参照してください。

※ pgrex02でPostgreSQLリソースがPrimaryとして稼働中のため、pgrex01をStandbyとして起動します。

::: {custom-style="page-break"}
　
:::

【STEP8：ノード状態・リソース状態確認 \[pgrex01\]】

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
  [\ \ \*\ fence2\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

IC-LAN故障
----------

この節では、IC-LAN故障時の対処について説明します。

::: {custom-style="First Paragraph"}
　
:::

### 故障時のHAクラスタ状態

IC-LAN故障を検知し、reset処理を実行しています。
reset処理の実行状況により、HAクラスタおよびデータベースサービスの状態は以下のようになります。

(1) pgrex01からpgrex02へのreset処理が成功した場合

    pgrex02がreset処理によりPacemakerを停止し、IPaddr2リソース(ipaddr-standby)がpgrex01へ移動します。

    データベースサービスは片方のノード(pgrex01)で継続しています。

(2) pgrex02からpgrex01へのreset処理が成功した場合

    pgrex01がreset処理によりPacemakerを停止し、pgrex02のPostgreSQLリソース(pgsql)がPrimaryへ昇格し、pgrex01のIPaddr2リソース(ipaddr-primary、ipaddr-replication)がpgrex02へ移動します。

    データベースサービスは片方のノード(pgrex02)で継続しています。

(3) 両方のノードからのreset処理が失敗した場合

    pgrex01はPrimaryのままで、pgrex02はStandbyのままでそれぞれ相手ノードに対してreset処理を繰り返しています。

    データベースサービスは両ノードで継続しています。

::: {custom-style="First Paragraph"}
　
:::

### 復旧

pgrex01がPrimaryの場合の復旧手順を以下に説明します。

pgrex02がPrimaryの場合は、pgrex01とpgrex02を読み替えて下さい。

::: {custom-style="First Paragraph"}
　
:::

【STEP1：強制電源断 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

この作業は、pgrex02のノードの状態がOFFLINEとなって**いない**場合に実施します。

pgrex02の電源ボタンを押下し、電源を停止します。

::: {custom-style="page-break"}
　
:::

【STEP2：ノード状態・リソース状態確認 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

ノード状態とリソース状態が以下のとおりとなっていることを確認し、【STEP4】へ進みます。

pgrex02のノード状態がOFFLINEとなっていない場合は、【STEP3】へ進みます。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# pcs status \-\-full]{custom-style="Verbatim Char"}\
  [：（略）]{custom-style="Verbatim Char"}\
  [\ \*\ Last\ updated:\ ]{custom-style="Verbatim Char"}[日付表示]{custom-style="italic"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [Node List:]{custom-style="Verbatim Char"}\
  [\ \*\ Online:\ \[\ pgrex01\ (1)\]]{custom-style="Verbatim Char"}\
  [\ \*\ OFFLINE:\ \[\ pgrex02\ (2)\]]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}\
  \
  [\ \*\ Clone\ Set:\ pgsql\-clone\ \[pgsql\]\ (promotable)\:]{custom-style="Verbatim Char"}\
  [\ \ \*\ pgsql]{custom-style="Verbatim Char"}\	[\ (ocf::linuxhajp:pgsql):]{custom-style="Verbatim Char"}[\ Master\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ Resource\ Group:\ primary\-group:]{custom-style="Verbatim Char"}\
  [\ \ \*\ ipaddr\-primary\ \ \ \ \ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \ \*\ ipaddr\-replication\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [\ \*\ ipaddr\-standby\ (ocf::heartbeat:IPaddr2):]{custom-style="Verbatim Char"}\	\	[\ \ Started]{custom-style="Verbatim Char"}[\ pgrex01]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

【STEP3：保守者介在処理 \[pgrex01\]】

::: {custom-style="First Paragraph"}
　
:::

手動でpgrex02を停止させたことをHAクラスタに通知するために、stonith\_adminコマンドによる保守者介在処理を行います。

pgrex01で\"pacemaker-controld.\*notice:.\*was not terminated.\*\"をキーワードとし、/var/log/messagesに以下のログが出力されていることを確認します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [Jan\ 23\ 15:49:27\ pgrex01\ pacemaker\-controld\[1531920\]:\ notice:\ ]{custom-style="Verbatim Char"}[Peer\ pgrex02\ was\ not\ terminated\ (reboot)]{custom-style="red-bold"}[\ by\ ]{custom-style="Verbatim Char"}[pgrex01]{custom-style="italic"}[\ on\ behalf\ of\ pacemaker\-controld\.1531920:\ ]{custom-style="Verbatim Char"}[エラー内容]{custom-style="italic"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

pgrex01でstonith\_adminコマンドを以下のとおり実施します。

実施後、再度ノード状態を確認するため、【STEP2】へ戻ります。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# stonith_admin \-C\ ]{custom-style="Verbatim Char"}[pgrex02]{custom-style="italic"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

【STEP4：ノード起動 \[pgrex02\]】

::: {custom-style="First Paragraph"}
　
:::

この作業は、【STEP1】で、電源を停止した場合のみ実施します。

pgrex02の電源ボタンを押下し、ノードを起動します。

::: {custom-style="First Paragraph"}
　
:::

【STEP5：保守者へ報告】

::: {custom-style="First Paragraph"}
　
:::

以下の内容を報告します。

-   報告時点でのデータベースサービス稼働状況(pgrex01でデータベースサービス継続中)

-   報告時点でのHAクラスタ状態(pgrex02でPacemaker停止中)

-   故障箇所(IC-LAN故障が発生)

::: {custom-style="First Paragraph"}
　
:::

【STEP6：保守者による故障復旧】

::: {custom-style="First Paragraph"}
　
:::

保守者が故障復旧を実施します。

::: {custom-style="First Paragraph"}
　
:::

【STEP7：Pacemaker起動 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

pgrex02のPacemakerを起動します。起動する手順は『Standbyの起動』を参照してください。

::: {custom-style="First Paragraph"}
　
:::

【STEP8：ノード状態・リソース状態確認 [pgrex02]】

::: {custom-style="First Paragraph"}
　
:::

ノードとリソース状態が以下のとおりとなっていることを確認します。

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
  [\ \*\ fence1\-ipmilan\ \ \ (stonith:fence_ipmilan):]{custom-style="Verbatim Char"}\	[Started]{custom-style="Verbatim Char"}[\ pgrex02]{custom-style="red-bold"}\
  [：（略）]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------
