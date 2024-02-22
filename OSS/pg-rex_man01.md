はじめに
========

本マニュアルの目的
----------

本マニュアルは、PostgreSQL-REX13(以降、PG-REXと呼ぶ)の技術情報を説明します。本マニュアルの目的は、読者が、PG-REXの動作環境を構築し、PG-REXを操作できるようになることです。

対象読者
--------

本マニュアルは、PG-REXの環境構築やシステム運用を行うエンジニアを対象読者としています。また、本マニュアルでは本文中で以下のドキュメントやインターネット上の関連サイトを参照します。

::: {custom-style="First Paragraph"}
　
:::

Pacemaker関連サイト

-   [https://clusterlabs.org/pacemaker/doc](https://clusterlabs.org/pacemaker/doc) (マニュアル[^56])
-   [https://clusterlabs.org](https://clusterlabs.org) (Linux-HAのメインサイト)
-   [https://linux-ha.osdn.jp/wp](https://linux-ha.osdn.jp/wp) (Linux-HA Japanプロジェクトのサイト)
-   [https://ja.osdn.net/projects/linux-ha](https://ja.osdn.net/projects/linux-ha) (Linux-HA Japanの開発者向のサイト)

    ⇒本マニュアルでは、上記をまとめて『Pacemaker関連サイト』と呼びます。

::: {custom-style="First Paragraph"}
　
:::

PostgreSQL 13付属ドキュメント

-   [https://www.postgresql.jp/document/13](https://www.postgresql.jp/document/13)

    ⇒本マニュアルでは、『PostgreSQLドキュメント』と呼びます

::: {custom-style="page-break"}
　
:::


表記規則
--------

本マニュアルでは、以下の表記規則を使用します。なお、用語説明は、『用語集』に掲載されています。


* 『』 : 本マニュアル内で参照する書名（本マニュアルの章見出し等も含む）
  - 『Pacemaker関連サイト』
* *斜体* : 環境に応じて変更する項目
  - [eno1]{custom-style="italic"}
* \# : rootユーザの操作記号
  - [\# pcs status]{custom-style="Verbatim Char"}
* \$ : 一般ユーザの操作記号
  - [\$ psql]{custom-style="Verbatim Char"}
* [赤太字]{custom-style="red-bold"} : 端末操作においてユーザが意識すべき箇所
  - [PGDATA=/dbfp/pgdata/data]{custom-style="red-bold"}

::: {custom-style="page-break"}
　
:::

対象とするソフトウェアとバージョン {#sec:対象とするソフトウェアとバージョン}
-------------------------

対象とするソフトウェアとバージョンは以下の通りです。Errataの適用が必要となる場合、表の各ソフトウェアのバージョンの後ろに”+”をつけて示しました。

また、本マニュアルの実行例はRed Hat Enterprise Linux 8.4の環境でのものです。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするOSとバージョン
:::

  ----------------------------------------------------------------------------------
  OS                                                     バージョン
  ------------------------------------------------------ -------------------
  Red Hat Enterprise Linux[^49]                          8.4, 8.5, 8.6
  
  Red Hat Enterprise Linux High Availability Add-On[^50] 8.4 + RHBA-2021:1996,\
                                                         8.5, 8.6

  ----------------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするミドルウェアとバージョン
:::
  ----------------------------------------------------------------------------------
  ミドルウェア                                           バージョン
  ------------------------------------------------------ -------------------
  PostgreSQL                                             13

  Pacemaker                                              2.0.5-9[^52], 2.1.0-8[^54], 2.1.2-4[^55]

  pm_extra_tools                                         1.4

  PG-REX運用補助ツール                                   13.1

  ----------------------------------------------------------------------------------

前提条件
--------

本マニュアルに記載されているコマンド実行例は、LANG=ja\_JP.UTF-8を前提にしています。LANGの設定によっては、出力メッセージなど実行例の内容が本マニュアルと異なる可能性があるため注意してください。例えば、PostgreSQL関連のツールは、LANG=ja\_JP.UTF-8では日本語でメッセージ等を出力します[^2]が、LANG=Cの場合は英語で出力します。

また、コンソールの表示はOSのバージョンによって異なる場合があります。

本マニュアルでは、PG-REXを構成するサーバをノードと呼びます。また、PG-REXを構成する2つのノードの名前（uname -nの結果）をpgrex01、pgrex02とします。

