はじめに
========

本書の目的
----------

本書は、PostgreSQL-REX12(以降、PG-REXと呼ぶ)の技術情報を説明します。本書の目的は、読者が、PG-REXの動作環境を構築し、PG-REXを操作できるようになることです。

対象読者
--------

本書は、PG-REXの環境構築やシステム運用を行うエンジニアを対象読者としています。また、本書では本文中で以下のドキュメントやインターネット上の関連サイトを参照します。

::: {custom-style="First Paragraph"}
　
:::

Pacemaker関連サイト

-   [http://clusterlabs.org/doc/en-US/Pacemaker/2.0/html/Pacemaker_Explained/index.html](http://clusterlabs.org/doc/en-US/Pacemaker/2.0/html/Pacemaker_Explained/index.html) (本家マニュアル)
-   [http://clusterlabs.org](http://clusterlabs.org) (Linux-HAのメインサイト(英語))
-   [http://linux-ha.osdn.jp](http://linux-ha.osdn.jp) (Linux-HA Japanプロジェクトのサイト)
-   [http://ja.osdn.net/projects/linux-ha](http://ja.osdn.net/projects/linux-ha) (Linux-HA Japanの開発者向のサイト)

    ⇒本書では、上記をまとめて『Pacemaker関連サイト』と呼びます。

::: {custom-style="First Paragraph"}
　
:::

PostgreSQL 12付属ドキュメント

-   [http://www.postgresql.jp/document/12](http://www.postgresql.jp/document/12)

    ⇒本書では、『PostgreSQLドキュメント』と呼びます

::: {custom-style="page-break"}
　
:::


表記規則
--------

本書では、以下の表記規則を使用します。なお、用語説明は、『用語集』に掲載されています。


* 『』 : 本書内で参照する書名（本書の章見出し等も含む）
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

対象とするソフトウェアとバージョン
-------------------------

対象とするソフトウェアとバージョンは以下の通りです。Errataの適用が必要となる場合、表の各ソフトウェアのバージョンの後ろに”+”をつけて示しました。

また、本書の実行例はRed Hat Enterprise Linux 8.4の環境でのものです。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするOSとバージョン
:::

  ----------------------------------------------------------------------------------
  OS                                                     バージョン
  ------------------------------------------------------ -------------------
  Red Hat Enterprise Linux[^48]                          8.4
  
  Red Hat Enterprise Linux High Availability Add-On[^49] 8.4 + RHBA-2021:1996

  ----------------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするミドルウェアとバージョン
:::
  ----------------------------------------------------------------------------------
  ミドルウェア                                           バージョン
  ------------------------------------------------------ -------------------
  PostgreSQL                                             12[^50]

  Pacemaker                                              2.0.5-9[^51]

  pm_extra_tools                                         1.3

  運用補助ツール                                         12.1

  ----------------------------------------------------------------------------------
前提条件
--------

本書に記載されているコマンド実行例は、LANG=ja\_JP.UTF-8を前提にしています。LANGの設定によっては、出力メッセージなど実行例の内容が本書と異なる可能性があるため注意してください。例えば、PostgreSQL関連のツールは、LANG=ja\_JP.UTF-8では日本語でメッセージ等を出力します[^2]が、LANG=Cの場合は英語で出力します。

また、コンソールの表示はOSのバージョンによって異なる場合があります。

本書では、PG-REXを構成するサーバをノードと呼びます。また、PG-REXを構成する2つのノードの名前（uname -nの結果）をpgrex01、pgrex02とします。

