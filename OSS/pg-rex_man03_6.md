リソースの設定
--------------

本マニュアルとセットで提供されるPG-REX用の『pm_pcsgen環境定義書』を用いて、クラスタ内のリソース構成、動作条件、パラメータ、配置制約などを設定します。

::: {custom-style="First Paragraph"}
　
:::

### pm\_pcsgenの概要

pm\_pcsgenは『pm\_pcsgen環境定義書』からxmlファイルを生成するツールです。生成されたxmlファイルをPG-REX運用補助ツールあるいはpcsコマンドを使用してPacemakerに読みませることで、ファイルの内容が反映されます。

PG-REXでのxmlファイル生成までの手順は以下のとおりです。

(1) PG-REX用の『pm\_pcsgen環境定義書』を編集する。
(2) 編集した『pm\_pcsgen環境定義書』をcsvファイル形式に変換し、pgrex01に転送する。
(3) pgrex01上でpm\_pcsgenコマンドを使用し、csvファイルをxmlファイルに変換する。

::: {custom-style="First Paragraph"}
　
:::

以降、『pm\_pcsgen環境定義書』の設定方法を説明します。

::: {custom-style="First Paragraph"}
　
:::

### 変更不要の設定

『pm\_pcsgen環境定義書』の下記の設定は変更不要です。

-   表1-1 クラスタ・ノード属性
-   表2-1 クラスタ・プロパティ
-   表3-1 リソース・デフォルト
-   表3-2 オペレーション・デフォルト
-   表5-1 リソース・パラメータ
-   表6-1 STONITHの実行順序
-   表10-1 リソース同居制約
-   表11-1 リソース起動順序制約
-   表12-1 ALERT設定
-   表13-1 追加設定

::: {custom-style="page-break"}
　
:::

### リソース(Primary側仮想IPアドレス)の設定

『pm\_pcsgen環境定義書』の表7-1にPostgreSQLのPrimary側接続用の仮想IPアドレスを設定します。

『pm\_pcsgen環境定義書』の表7-1にレプリケーション受付用の仮想IPアドレスを設定します。

::: {custom-style="First Paragraph"}
　
:::

### PG-REXにおけるPostgreSQL制御の設定 {#sec:PG-REXにおけるPostgreSQL制御の設定}

『pm\_pcsgen環境定義書』の表7-1にPostgreSQLの制御に必要な設定をします。PG-REXを構成するのに必要な設定、注意すべき設定は以下のとおりです。

::: {custom-style="Table Caption"}
PG-REXにおけるPostgreSQL制御の設定
:::

  ----------------------------------------------------------------------------------
  パラメータ名         設定値                  備考
  -------------------- ----------------------- -------------------------------------
  rep_mode             sync                    PG-REXでは常にsyncを指定する。

  node_list            pgrex01 pgrex02         HAクラスタを構成するノードの名前を設定する。\
                                               (ノードの名前の間はスペース区切り)

  master_ip            192.168.2.3             『pm\_pcsgen環境定義書』の表7-1に設定\
                                               したレプリケーション受付用の仮想IPアドレ\
                                               スを設定する。

  restore_command      /bin/cp\                アーカイブディレクトリからWALファイルを\
                       /dbfp/pgarch/arc1/%f %p リストアするためのコマンドを設定する。\
                                               アーカイブコマンド[^17]に対応したコマンドを\
                                               設定すること。\
                                               (参考)\
                                               アーカイブコマンドでgzipを使用した場合は\
                                               リストアコマンドにもgzipを使用すること。\
                                               コマンド設定例を以下に示す。\
                                               \'/bin/gzip -cd /dbfp/pgarch/arc1/%f.gz > %p\'

  repuser              repuser                 『[@sec:レプリケーションユーザの作成](#sec:レプリケーションユーザの作成) [レプリケーションユーザの作成](#sec:レプリケーションユーザの作成)』で\
                                               作成したレプリケーションユーザを設定する。

  primary_conninfo_opt keepalives_idle=60\     TCPキープアライブ用の制御パラメータを\
                       keepalives_interval=5\  設定する。PG-REXでは左記の設定値を\
                       keepalives_count=5      推奨する。\
                                               \
                                               \
                                               \

  stop_escalate        0                       このパラメータは、Primary停止時に\
                                               PostgreSQLの高速シャットダウンを実行して\
                                               から即時シャットダウンにエスカレーション\
                                               するまでの待ち時間を設定する。\
                                               0を設定した場合、高速シャットダウンは実行\
                                               されずに、即座に即時シャットダウンが実行\
                                               される。

  xlog_check_count     0                       このパラメータは、2つのノードを同時に\
                                               起動する際、どちらがPrimaryとして\
                                               起動するかをチェックする回数を設定する\
                                               （デフォルトは3）。\
                                               このパラメータを設定すると、Primary起動の\
                                               際にmonitor間隔×設定値の時間だけ\
                                               Standbyで待機することになり、その分\
                                               Primaryとして起動する時間が遅くなる。\
                                               本マニュアルでは、2つのノードを同時に\
                                               起動するケースがないため、0を設定する。

  ----------------------------------------------------------------------------------
    

::: {custom-style="First Paragraph"}
　
:::

### リソース(ネットワーク監視)の設定

『pm\_pcsgen環境定義書』の表7-1にネットワーク監視を設定します。なお、PG-REXではS-LANを監視します。監視するネットワークのIPアドレスとしてS-LANのデフォルトゲートウェイ等を設定してください。

::: {custom-style="First Paragraph"}
　
:::

### リソース(STONITH)の設定

『pm\_pcsgen環境定義書』の表8-1、表9-1にSTONITHを設定します。

::: {custom-style="First Paragraph"}
　
:::

### リソース(Standby側仮想IPアドレス)の設定

Standbyへのデータベース接続を利用する場合は、『pm\_pcsgen環境定義書』の表7-1にStandby側接続用の仮想IPアドレスを設定します。Standbyへのデータベース接続を利用しない場合は、『pm\_pcsgen環境定義書』の表4-1、表7-1、表9-2からipaddr-standbyの設定値をコメントアウトします。

::: {custom-style="page-break"}
　
:::

### xmlファイルの作成

以下の操作を行い、xmlファイルを作成します。なお、作成したxmlファイルをPrimary起動時に指定することでPacemakerに反映されます。

本作業はrootユーザで行います。

::: {custom-style="First Paragraph"}
　
:::

(1) Microsoft®
    Excelを使って『pm\_pcsgen環境定義書』のシートを修正してCSV形式で保存します。

    本マニュアルではファイル名は「pm\_pcsgen\_env.csv」とします。

    ::: {custom-style="First Paragraph"}
    　
    :::

(2) 保存したcsvファイル（pm\_pcsgen\_env.csv）を、pgrex01に転送します。

    ファイル転送の際に文字コード変換を行わないよう注意してください。

    ::: {custom-style="First Paragraph"}
    　
    :::

(3) pgrex01上で、pm\_pcsgenコマンドを使用し、転送したcsvファイルをxmlファイルに変換します。

    本マニュアルでは、変換後のファイル名を「pm\_pcsgen\_env.xml」とします[^46]。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# pm_pcsgen pm_pcsgen_env.csv]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

