PG-REX運用補助ツール
--------------------

本節では、PG-REX運用補助ツールのインストールおよび基本設定について説明します。

本節の作業はrootユーザで行います。

### インストール

pgrex01とpgrex02へPG-REX運用補助ツールをインストールします。

::: {custom-style="First Paragraph"}
　
:::

PG-REX運用補助ツールのインストール必須のRPMパッケージを以下に示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [pg\-rex_operation_tools_script\-15.1\-1.el8.noarch.rpm]{custom-style="Verbatim Char"}\
  [IO_Tty\-1.11\-1.el8.x86_64.rpm]{custom-style="Verbatim Char"}\
  [Net_OpenSSH\-0.62\-1.el8.x86_64.rpm]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

PG-REX運用補助ツールをRPMパッケージからインストールします。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [# yum\ install\ pg\-rex_operation_tools_script\-15\.1\-1\.el8\.noarch\.rpm\ IO_Tty\-1\.11\-1\.el8\.x86_64\.rpm\ Net_OpenSSH\-0\.62\-1\.el8\.x86_64\.rpm]{custom-style="Verbatim Char"}\
  \
  [※ バージョンは適宜読み替えてください。]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### pg-rex\_tools.confの編集

pgrex01とpgrex02で/etc/pg-rex\_tools.confの設定を行います。PG-REX運用補助ツールを使用するために必要な設定、および注意すべき設定は以下のとおりです。

::: {custom-style="First Paragraph"}
　
:::

-   [D_LAN\_IPAddress]{custom-style="bold"}

    両ノードのD-LAN IPアドレスをカンマ区切りで設定する。

-   [IC_LAN\_IPAddress]{custom-style="bold"}

    IC-LAN系統ごとに括弧で括ったIPアドレスの組を2系統分記述する。

-   [Archive\_dir]{custom-style="bold"}

    アーカイブディレクトリの絶対パスを設定する。

-   [IPADDR\_STANDBY]{custom-style="bold"}

    Standby側接続用の仮想IPアドレスを使用する環境の場合はenable、それ以外の場合はdisableを設定する。

-   [HACLUSTER\_NAME]{custom-style="bold"}

    Pacemakerで管理するHAクラスタ名を指定します。HAクラスタ名には英数字とアンダースコア、およびハイフンのみ使用可です。ただし先頭にはハイフンは使用できません。これ以外のPacemakerで許されている文字をHAクラスタ名に使用したい場合は、PG-REX運用補助ツールを使用せず、『[@sec:コマンド直接実行の運用](#sec:コマンド直接実行の運用) [コマンド直接実行の運用](#sec:コマンド直接実行の運用)』の手順で構築してください。

::: {custom-style="First Paragraph"}
　
:::

設定例を以下に示します。

::: {custom-style="First Paragraph"}
　
:::

  ------------------------------------------------------------------------
  [D\_LAN_IPAddress = 192.168.2.1, 192.168.2.2]{custom-style="Verbatim Char"}\
  [IC\_LAN\_IPAddress = (192.168.1.1, 192.168.1.2) , (192.168.3.1, 192.168.3.2)]{custom-style="Verbatim Char"}\
  [Archive_dir = /dbfp/pgarch/arc1]{custom-style="Verbatim Char"}\
  [IPADDR_STANDBY = disable]{custom-style="Verbatim Char"}\
  [HACLUSTER\_NAME = pgrex\_cluster]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

### ネットワーク接続登録

PG-REX運用補助ツールが相手ノードの操作や確認をD-LANを使用して行うため、事前に両ノードのrootユーザの.ssh/known_hostsに相手先のD-LANのIPアドレスに対する接続登録をする必要があります。

::: {custom-style="First Paragraph"}
　
:::

(1) pgrex01からD-LAN経由でpgrex02へ接続します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# ssh 192.168.2.2]{custom-style="Verbatim Char"}\
  [The authenticity of host \'192.168.2.2 (192.168.2.2)\' can\'t be established.]{custom-style="Verbatim Char"}\
  [ECDSA key fingerprint is \*\*\*\*\*\*\*]{custom-style="Verbatim Char"}\
  [Are you sure you want to continue connecting (yes/no/\[fingerprint\])?\ ]{custom-style="Verbatim Char"}[yes]{custom-style="red-bold"}\
  [Warning: Permanently added \'192.168.2.2\' (ECDSA) to the list of known hosts.]{custom-style="Verbatim Char"}\
  [root@192.168.2.2\'s password:]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="First Paragraph"}
　
:::

(2) pgrex02からD-LAN経由でpgrex01へ接続します。

    ::: {custom-style="First Paragraph"}
    　
    :::

  ------------------------------------------------------------------------
  [# ssh 192.168.2.1]{custom-style="Verbatim Char"}\
  [The authenticity of host \'192.168.2.1 (192.168.2.1)\' can\'t be established.]{custom-style="Verbatim Char"}\
  [ECDSA key fingerprint is \*\*\*\*\*\*\*]{custom-style="Verbatim Char"}\
  [Are you sure you want to continue connecting (yes/no/\[fingerprint\])?\ ]{custom-style="Verbatim Char"}[yes]{custom-style="red-bold"}\
  [Warning: Permanently added \'192.168.2.1\' (ECDSA) to the list of known hosts.]{custom-style="Verbatim Char"}\
  [root@192.168.2.1\'s password:]{custom-style="Verbatim Char"}

  ------------------------------------------------------------------------

::: {custom-style="page-break"}
　
:::

