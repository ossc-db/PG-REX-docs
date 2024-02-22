環境構築
========

本章では、ネットワークの構成、ディレクトリ構成、および、PG-REXのインストール手順を説明します。

ネットワーク
------------

### ネットワーク構成例

PG-REXが推奨するネットワーク構成例を次ページに示します。この構成例では、各ノードにNWインターフェイスが7つある構成となっています。実際のノードのNWインターフェイスの数に応じてbonding等の設定を見直して環境を作成してください。

::: {custom-style="First Paragraph"}
また、この構成例では、D-LANおよびSTONITH-LANについて、以下のような記述となっています。

D-LANにおいてbonding設定を行ったNWインターフェイス同士を直接接続していますが、実際にはスイッチを介して接続することを推奨します。スイッチを使用せずに直接接続した場合、環境によってはOSによる故障検知に失敗する可能性があります。

STONITH-LANは、物理環境が前提となっていますが、仮想環境で構築する場合はネットワークを読み替えてください。
:::


::: {custom-style="page-break"}
　
:::

  ![](media/image1.png)

::: {custom-style="Figure Caption"}
ネットワーク構成例
:::

::: {custom-style="First Paragraph"}
　
:::

::: {custom-style="page-break"}
　
:::

### 本マニュアルで使用するIPアドレス

本マニュアルでは以下のIPアドレスを使用します。

PG-REXでは、運用LANにおけるPostgreSQL接続用、およびDBレプリケーションLANにおけるレプリケーション受付用に仮想IPアドレスを使用します。
この仮想IPアドレスは、環境定義書の記載内容にしたがって、Pacemaker側で作成します。

::: {custom-style="First Paragraph"}
　
:::

-   S-LAN(運用LAN)
    :   -   pgrex01-bond0(eno0, eno5) : 192.168.0.11
        -   pgrex02-bond0(eno0, eno5) : 192.168.0.12
        -   PING監視先(GW等) : 192.168.0.254
        -   PostgreSQL Primary接続用仮想IPアドレス
            - bond0(eno0, eno5) : 192.168.0.10
        -   PostgreSQL Standby接続用仮想IPアドレス
            - bond0(eno0, eno5) : 192.168.0.20
-   D-LAN(DBレプリケーションLAN)
    :   -   pgrex01-bond1(eno2, eno4) : 192.168.2.1
        -   pgrex02-bond1(eno2, eno4) : 192.168.2.2
        -   レプリケーション受付用仮想IPアドレス
            -    bond1(eno2, eno4) : 192.168.2.3
-   IC-LAN(インターコネクトLAN)
    :   -   pgrex01-eno1 : 192.168.1.1
        -   pgrex01-eno3 : 192.168.3.1
        -   pgrex02-eno1 : 192.168.1.2
        -   pgrex02-eno3 : 192.168.3.2
-   STONITH-LAN
    :   -   pgrex01-eno6 : 172.20.144.41
        -   pgrex02-eno6 : 172.20.144.42
        -   pgrex01-HW制御ボード  : 172.20.144.43
        -   pgrex02-HW制御ボード  : 172.20.144.44

::: {custom-style="First Paragraph"}
　
:::

※ ネットマスクはすべてのIPアドレスについて24 (255.255.255.0) とします。

::: {custom-style="page-break"}
　
:::

ディレクトリ構成
----------------

PG-REXのディレクトリ構成例を以下に示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [/var]{custom-style="Verbatim Char"}\
  [\ \ +\-lib]{custom-style="Verbatim Char"}\
  [\ \ \ \ \ +\-pgsql\ \.\.\.\.\.\.\.\.\.\ postgresユーザのホームディレクトリ]{custom-style="Verbatim Char"}\
  \
  [/dbfp]{custom-style="Verbatim Char"}\
  [\ \ +\-pgdata]{custom-style="Verbatim Char"}\
  [\ \ |\ \ +\-data\ \.\.\.\.\.\.\.\.\.\.\ PostgreSQLのDBクラスタ]{custom-style="Verbatim Char"}\
  [\ \ +\-pgwal]{custom-style="Verbatim Char"}\
  [\ \ |\ \ +\-pg_wal\ \.\.\.\.\.\.\.\.\ PostgreSQLのWAL格納先]{custom-style="Verbatim Char"}\
  [\ \ +\-pgarch]{custom-style="Verbatim Char"}\
  [\ \ \ \ \ +\-arc1\ \.\.\.\.\.\.\.\.\.\.\ PostgreSQLのアーカイブログ格納先]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

この構成例では、PostgreSQLのDBクラスタ、WAL、アーカイブログの各格納先を別ディレクトリに配置しています。実際のディスク構成に応じて配置先を見直して環境を作成してください。ただし、両ノード（pgrex01とpgrex02）のディレクトリ構成は同一にしてください。

本マニュアルでは、この構成例を前提に記述します。

::: {custom-style="page-break"}
　
:::

