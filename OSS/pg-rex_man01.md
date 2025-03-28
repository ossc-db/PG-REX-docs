はじめに
========

本マニュアルの目的
----------

本マニュアルは、PostgreSQL-REX17(以降、PG-REXと呼ぶ)の技術情報を説明します。本マニュアルの目的は、読者が、PG-REXの動作環境を構築し、PG-REXを操作できるようになることです。

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

PostgreSQL 17付属ドキュメント

-   [https://www.postgresql.jp/document/17](https://www.postgresql.jp/document/17)

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

対象とするソフトウェアとバージョンは以下の通りです。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするOSとバージョン
:::

  ----------------------------------------------------------------------------------
  OS                                                     バージョン
  ------------------------------------------------------ ----------------------
  Red Hat Enterprise Linux[^48]                          9.4
  
  Red Hat Enterprise Linux High Availability Add-On[^49] 9.4 + RHBA-2024:6176

  ----------------------------------------------------------------------------------

※ Errataの適用が必要となる場合、表の各ソフトウェアのバージョンの後ろに”+”をつけてErrataの番号を示します。

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="Table Caption"}
対象とするミドルウェアとバージョン
:::
  ----------------------------------------------------------------------------------
  ミドルウェア                                           バージョン
  ------------------------------------------------------ -------------------
  PostgreSQL                                             17

  Pacemaker                                              2.1.7-5.2(9.4)

  pcs                                                    0.11.7-2(9.4)

  pm_extra_tools                                         1.6

  PG-REX運用補助ツール                                   17.0

  Net_OpenSSH                                            0.62-1

  perl-IO-Tty                                            1.16-4
  ----------------------------------------------------------------------------------

※ Pacemakerおよびpcsのバージョンの後に括弧で書かれている数値は、同梱されているRHEL HA Add-Onのバージョンを示します。Errata適用時はErrata適用後のバージョンとなります。

::: {custom-style="page-break"}
　
:::

前提条件
--------

本マニュアルの前提条件を以下に示します。

* 本マニュアルの実行例は、以下を前提とします。
  - Red Hat Enterprise Linux 9.4 上での実行です。コンソールの表示は OS のバージョンによって異なることがあります。
  - LANGの設定はLANG=ja_JP.UTF-8です。設定によっては、出力メッセージなどが掲載した例と異なることがあります。例えば、PostgreSQL関連のツールのメッセージはLANG=ja_JP.UTF-8では日本語です[^2] が、LANG=Cの場合は英語です。
* PG-REXを構成するサーバをノードと呼びます。また、PG-REXを構成する2つのノードの名前（uname -nの結果）をpgrex01、pgrex02とします。


